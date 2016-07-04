# This file will do anything can can only be done after the source
# tree has been traversed.

# Check to make sure all of the locations have been defined.
location_error = $(error "LOCATION_$1 not defined")
is_undefined   = $(call seq,$(origin LOCATION_$1),undefined)
assert_loc     = $(if $(call is_undefined,$1),$(call location_error,$1),)

$(call map,assert_loc,$(ALL_LOCATIONS))
