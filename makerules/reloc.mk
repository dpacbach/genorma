# This make file will detect if the auto-dependency files need
# to be processed to have to paths adjusted to be relative to the
# current working directory.  This is needed because the .d files
# (written by gcc) will always contain paths relative to the PWD.
# Since the user could then run make from another PWD (which will
# cause the paths in the targets to change) the existing .d files
# would become invalid.  If we detect that we've changed PWD since
# the last time running make then we will invoke a shell script
# (which then invokes a perl script) to do the reprocessing.
$(call assert,$(TOPLEVELWD),TOPLEVELWD not defined!)

reloc_sh      := $(CWD)scripts/reloc.sh
location_file := $(TOPLEVELWD).location
top_wd        := $(abspath $(TOPLEVELWD))
# This is the system's current working directory from which we
# invoked make.
new_wd        := $(abspath $(PWD))
# This is the function that will record the new PWD in the marker
# file.
update_location = $(shell echo $(new_wd) > $(location_file))

# Don't do anything here if the target is "clean" because in
# that case all the .d files and location file will be deleted
# anyway.
ifneq ($(MAKECMDGOALS),clean)
    # If the marker file doesn't exist then just update it so that
    # the `cat' command that follows won't get mad.
    ifeq ($(wildcard $(location_file)),)
        $(call update_location)
    endif
    # This is where the user previously ran make from.
    last_wd := $(shell cat $(location_file))
    # If we've changed locations then we should reprocess the .d's.
    ifneq ($(last_wd),$(new_wd))
        $(shell $(reloc_sh) $(top_wd) $(last_wd) $(new_wd) 1>&2)
        # Update with our new location
        $(call update_location)
    endif
endif
