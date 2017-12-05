# ===============================================================
# General dependencies processing
first_level_deps = $($(1).deps)
expand_deps_1    = $(call map,first_level_deps,$1)
# This will recursively expand a single location into a full list
# of all dependencies, including  itself  (there  may be redunden-
# cies). Note: it is important (given what follows later) to  put
# self before the dependencies.
expand_deps_full = $1 $(call map,expand_deps_full,$(call expand_deps_1,$1))
# Now just remove redundencies with  the uniq function. Note that
# we are calling uniq on the  reverse  of the deps list. At first
# this reverse may seem to be  redundant,  but it is necessary be-
# cause the full deps list above will always put the dependencies
# after  self  (which  they need to be in order that dependencies
# appear in the right order on the linker command line)  but  the
# uniq method will keep only the first occurence of  an  item  in
# the list, whereas we actually  want  to  keep  only the last oc-
# curence  of  it  in order to preserve the property that, on the
# linker  command  line,  a library comes before all of its depen-
# dencies.
all_deps         = $(call on_reverse,uniq,$(call expand_deps_full,$1))
all_deps_noself  = $(filter-out $1,$(call all_deps,$1))

# ===============================================================
# Include dependencies
# ===============================================================
# Take a location, look up the associated folder,  and  make  the
# compiler option.
include_flag  = -I$(if $(LOCATION_$1),$(LOCATION_$1),.)
# Might want to try memoizing the results of this call since cur-
# rently it has to be recomputed for  every  file  in  a  library
# (gmsl has a memoizer).
include_flags = $(call map,include_flag,$(call all_deps,$1))

# ===============================================================
# Linking dependencies
# ===============================================================
# List only direct dependencies (not including self) and retrieve
# binary
link_binaries = $(foreach i,$(call all_deps_noself,$1),$($(i)_BINARY))
