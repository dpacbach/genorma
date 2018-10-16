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

# For example:
#   A/B/C.cpp ==> A/B/.lib-linux64/C.cpp.clang-tidy
clang-tidy-marker = $(call into_lib,$1.$(clang-tidy-target-suffix))

# Clang tidy will look here for compile flags.
compile_flags_txt := $(root)compile_flags.txt

# This python file is expected to be a symlink to the one in the
# nr-make repo.
$(compile_flags_txt):
	python $(root).ycm_extra_conf.py --src-file=$(firstword $(C_SRCS)) --compile-flags-txt=$@

# Currently the target depends on the source file so that it will
# be re-tidy'd when the source file is modified. But note that
# this may not be completely sufficient because it is likely
# that, in general, a cpp file will have to be re-tidy'd when a
# header file that it includes is modified. The below target is
# not smart enough to track those dependencies, but it should
# probably be sufficient in practice. Also note that the rule
# touches a marker file (the target) to only re-tidy when needed
# -- since the process is as slow as compilation we cannot afford
# to run this on every file if not needed.
#
# The rule also depends on a .clang-tidy file at the root. Note
# that this is just an approximation at best, and plain wrong at
# worst. More specifically, this will only work when the source
# tree is has just a single .clang-tidy file at the root that
# contains the rules for all source files, as opposed to other
# .clang-tidy files scattered throughout (which would override
# the one at the root). If there is no such file then it
# shouldn't cause any issues.
#
# The redirection of stderr to /dev/null is not ideal, but it is
# to suppress the "xxx warnings generated" output from clang tidy
# which the -quiet flag does not suppress for some reason. Any
# exceptions that clang-tidy finds (warnings/errors) will be
# output to stdout it seems, so we still get the colored output.
define __clang_tidy_rule
CLANG_TIDY_MARKERS := $(CLANG_TIDY_MARKERS) \
                      $(call clang-tidy-marker,$1)
$(call clang-tidy-marker,$1): $1 $(compile_flags_txt) $(wildcard $(root).clang-tidy)
	$(print_tidy) $(CLANG_TIDY) -quiet $1 2>/dev/null
	@touch $$@
endef

# This function will create a rule to run clang-tidy on one
# source file.
clang-tidy-rule = $(eval $(call __clang_tidy_rule,$1))

# Create a clang-tidy target for each source and header file.
$(call map,clang-tidy-rule,$(CH_SRCS))

tidy: $(call map,clang-tidy-marker,$(CH_SRCS))

.PHONY: tidy

# ===============================================================
# clang-format

clang-format-target-suffix := clang-format

# Currently the target depends on the source file just for the
# benefit of the printing code, so that it has access to the
# source filename.
define __clang_format_rule
$1.$(clang-format-target-suffix): $1
	$(print_cfmt) $(CLANG_FORMAT) -i $1
endef

# This function will create a rule to run clang-format on one
# source file.
clang-format-rule = $(eval $(call __clang_format_rule,$1))

# Create a clang-format target for each source and header file.
$(call map,clang-format-rule,$(CH_SRCS))

format: $(addsuffix .$(clang-format-target-suffix),$(CH_SRCS))

.PHONY: format

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
