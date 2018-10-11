# This  file  will  do  anything  can  can only be done after the
# source tree has been traversed.

# Load the remainder of  the  nr-make  modules  which can only be
# loaded after the source tree has been traversed.
include $(CWD)/post-config.mk

# ===============================================================
# Make sure all variables are defined that need to be  (but  note
# that they could be empty).

must_be_defined = CFLAGS CXXFLAGS LDFLAGS
$(call map,assert_defined,$(must_be_defined))

# Make sure all variables are non-empty that need to be
must_be_nonempty = CC CXX LD AR bin_folder          \
                   bin_name lib_name sub_locations
$(call map,assert_nonempty,$(must_be_nonempty))

# Here we get a list of all the file names of all binaries (which
# does not include object files) and assert that there are no du-
# plicates. There should not be  duplicates because we might want
# to copy them all into the same top-level folder.
bin_dup = duplicate file name in list of binaries!
$(call assert_no_dup,$(call map,notdir,$(BINARIES)),$(bin_dup))

# This file will dump some info on what tools are being used or
# the contents of certain variables if the user requested.
include $(CWD)/info.mk

# ===============================================================
# clang-tidy

clang-tidy-target-suffix := clang-tidy

# Currently the target depends on the source file just for the
# benefit of the printing code, so that it has access to the
# source filename.
define __clang_tidy_rule
$1.$(clang-tidy-target-suffix): $1
	$(print_tidy) clang-tidy $1
endef

# This function will create a rule to run clang-tidy on one
# source file.
clang-tidy-rule = $(eval $(call __clang_tidy_rule,$1))

# Create a clang-tidy target for each source and header file.
$(call map,clang-tidy-rule,$(CH_SRCS))

tidy: $(addsuffix .$(clang-tidy-target-suffix),$(CH_SRCS))

.PHONY: tidy

# ===============================================================
# Things having to do with bin/lib folders

ifneq (undefined,$(origin no_top_bin_folder))
    bin_folder = $(root)
endif

$(bin_folder):
	$(print_mkdir) mkdir -p $(bin_folder)

to_bin_folder = $(bin_folder)/$(notdir $1)

define __bin_copy_rule
    $(call to_bin_folder,$1): $1 | $(bin_folder)
	    $(print_copy_) cp -f $1 $$@
endef
# This function will create a rule to  copy  one  binary  to  the
# top-level binary folder. We won't actually call  this  function
# until after we have traversed the source tree.
bin_copy_rule = $(eval $(call __bin_copy_rule,$1))

# Create  a  bin_copy rule for each binary. These rules will copy
# binary  outputs  (which  do  not include object files) into the
# top-level binary folder.
$(call map,bin_copy_rule,$(bins_to_copy))

# When the user runs make  in  a subfolder without specifying any
# targets  then  this  default  target  will cause all targets to
# build whose locations are  subfolders  of  the  current  system
# folder. We take all of the binaries under the PWD and make them
# targets. This will have the effect of building not  only  them,
# but also their dependencies even if they are not under the PWD.
subfolders: $(call map,location_to_binary,$(sub_locations))
.PHONY: subfolders

# If  we  run make at the root of the project then just build the
# `all`  target which includes copying; otherwise, just build the
# binaries in the subfolders.
ifeq ($(pwd_rel_root),)
    .DEFAULT_GOAL := all
else
    .DEFAULT_GOAL := subfolders
endif

# If  the  project has defined which location holds the main exe-
# cutable binary then we  will  create  a  target called `run` so
# that  the  user can easily run the program from anywhere in the
# source tree by typing  `make  run`.  It  will first ensure that
# everything is fully build, then  will change into the top-level
# binary folder to run the binary in case we are  on  a  platform
# where it would otherwise not be able to find the  other  shared
# libraries that are also in the bin folder.
ifdef main_is
    # This is the file name of the  executable.  Assume  that  it
    # will be built as part of the `all` target and that it  will
    # be copied into the bin folder, wherever that is.
    main_name := $(notdir $(call location_to_binary,$(main_is)))
    run: all
	    $(at)cd $(bin_folder) && ./$(main_name)
    .PHONY: run
endif

# Same as above for main_is except for the testing executable.
ifdef test_is
    # This is the file name of the  executable.  Assume  that  it
    # will be built as part of the `all` target and that it  will
    # be copied into the bin folder, wherever that is.
    test_name := $(notdir $(call location_to_binary,$(test_is)))
    test: all
	    $(at)cd $(bin_folder) && ./$(test_name)
    .PHONY: run
endif
