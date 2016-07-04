# This file will do anything can can only be done after the source
# tree has been traversed.

is_location   = $(findstring LOCATION_,$1)
# Find all global variables of the form LOCATION_*
location_vars = $(call keep_if,is_location,$(.VARIABLES))
# Get the location name
all_locations = $(patsubst LOCATION_%,%,$(location_vars))

#####################################################################
# Make sure all variables are defined that need to be

must_be_defined = CFLAGS CXXFLAGS LD LDFLAGS
$(call map,assert_defined,$(must_be_defined))
