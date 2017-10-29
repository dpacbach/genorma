# ===============================================================
# Locations
# ===============================================================
# This contains a list of all locations encountered in the entire
# build tree, even ones which may not be built in this invocation
# of  make,  depending on the target requested and/or the current
# system directory.
all_locations :=
# This contains a list of only those locations which  are  at  or
# below the current system working directory.
sub_locations :=

# Registers  a  location. Also, if the path corresponding to this
# location  is  at  or below the current system working directory
# then  this  will  also  be recorded and later used to determine
# what to build when the user runs  make  in  a  sub  folder.  If
# pwd_rel_root is empty then this means that we are at the  root,
# so all locations are subfolder. Note that the LOCATION variable
# must be set because it is used by other makefiles.
define _set_location
    LOCATION    := $1
    LOCATION_$1 := $(relCWD)
    sub_locations += $(if $(pwd_rel_root),                      \
        $(if $(filter $(pwd_rel_root)/%,$(cwd_rel_root)/),$1,), \
        $1                                                      \
    )
    all_locations += $1
endef

set_location = $(eval $(call _set_location,$1))

location_to_binary = $($1_BINARY)
