ALL_LOCATIONS := CMD     \
                 TEST    \
                 LIB     \
                 LIB_INT

###############################################################################
# This is where all of the dependencies are specified.
CMD_deps  := LIB_INT
TEST_deps := LIB_INT
LIB_deps  := LIB_INT

###############################################################################
# Recursive expansion of dependencies
first_level_deps = $($1_deps)
expand_deps_1    = $(call map,first_level_deps,$1)
# This will recursively expand a single location into a full list of all
# dependencies, including itself (there may be redundencies).
expand_deps_full = $1 $(call map,expand_deps_full,$(call expand_deps_1,$1))
# Now just remove redundencies.
all_deps         = $(call uniq,$(call expand_deps_full,$1))

# Take a location, look up the associated folder, and make the compiler option.
include_flag  = -I$(if $(LOCATION_$1),$(LOCATION_$1),.)
# Might want to try memoizing the results of this call since currently it has
# to be recomputed for every file in a library (gmsl has a memoizer).
include_flags = $(call map,include_flag,$(call all_deps,$1))

###############################################################################
# Linking dependencies
###############################################################################
LINK_CMD     =
LINK_TEST    = $(LIB_BINARY)
LINK_LIB     =
LINK_LIB_INT =

###############################################################################
# Third-party dependencies
###############################################################################
# Include dependencies
TP_INCLUDES_CMD     :=
TP_INCLUDES_TEST    :=
TP_INCLUDES_LIB     := -I$(LIBXML2_INCLUDE)
TP_INCLUDES_LIB_INT :=

# Linker dependencies
TP_LINK_CMD     := -ldl
TP_LINK_TEST    :=
TP_LINK_LIB     := -lxml2
TP_LINK_LIB_INT :=
