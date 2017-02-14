# This  file  will  do  anything  can  can only be done after the
# source tree has been traversed.

is_location   = $(findstring LOCATION_,$1)
# Find all global variables of the form LOCATION_*
location_vars = $(call keep_if,is_location,$(.VARIABLES))
# Get the location name
all_locations = $(patsubst LOCATION_%,%,$(location_vars))

# ===============================================================
# Make sure all variables are defined that need to be  (but  note
# that they could be empty).

must_be_defined = CFLAGS CXXFLAGS LD LDFLAGS
$(call map,assert_defined,$(must_be_defined))

# Make sure all variables are non-empty that need to be
must_be_nonempty = bin_folder bin_name lib_name
$(call map,assert_nonempty,$(must_be_nonempty))

# Here we get a list of all the file names of all binaries (which
# does not include object files) and assert that there are no du-
# plicates. There should not be  duplicates because we might want
# to copy them all into the same top-level folder.
bin_dup = duplicate file name in list of binaries!
$(call assert_no_dup,$(call map,notdir,$(BINARIES)),$(bin_dup))

# Create  a  bin_copy rule for each binary. These rules will copy
# binary  outputs  (which  do  not include object files) into the
# top-level binary folder.
$(call map,bin_copy_rule,$(BINARIES))
