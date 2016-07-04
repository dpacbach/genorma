###############################################################################
# General dependencies processing
first_level_deps = $($(1).deps)
expand_deps_1    = $(call map,first_level_deps,$1)
# This will recursively expand a single location into a full list of all
# dependencies, including itself (there may be redundencies).
expand_deps_full = $1 $(call map,expand_deps_full,$(call expand_deps_1,$1))
# Now just remove redundencies.
all_deps         = $(call uniq,$(call expand_deps_full,$1))

###############################################################################
# Include dependencies
###############################################################################
# Take a location, look up the associated folder, and make the compiler option.
include_flag  = -I$(if $(LOCATION_$1),$(LOCATION_$1),.)
# Might want to try memoizing the results of this call since currently it has
# to be recomputed for every file in a library (gmsl has a memoizer).
include_flags = $(call map,include_flag,$(call all_deps,$1))

###############################################################################
# Linking dependencies
###############################################################################
# List only direct dependencies (not including self) and retrieve binary
link_binaries = $(foreach i,$(call expand_deps_1,$1),$($(i)_BINARY))
