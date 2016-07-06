makerules_location := $(dir $(lastword $(MAKEFILE_LIST)))
CWD := $(makerules_location)

################################################################################
# This is the `enter' function used to traverse folders.  It sets the
# variable CWD with the name of the current folder (relative to the
# system's current working directory) upon entering each new folder.
# This function is also used to enter into the makerules folder itself.
define enterimpl
    CWD_SP := $$(CWD_SP)_x
    $$(CWD_SP) := $$(CWD)
    CWD := $$(CWD)$1/
    #$$(info Entering $$(CWD))
    include $$(CWD)/makefile
    #$$(info Leaving $$(CWD))
    CWD := $$($$(CWD_SP))
    CWD_SP := $$(patsubst %_x,%,$$(CWD_SP))
endef

enter = $(eval $(call enterimpl,$1))
enter_all = $(call map,enter,$1)

################################################################################
# Traversal of makerules and source tree.  Entering into the makerules folder
# will load all of the makerules in that folder except for the ones explicitly
# loaded here.
#$(call enter,$(makerules_location))
include $(CWD)/makefile
# This is optional but, if present, should be loaded here
#-include $(TOPLEVELWD)/project.mk
# Now traverse the source tree
# These rules must go after the source tree is traversed
#include $(makerules_location)/postsrc.mk

################################################################################
# Standard top-level targets
#all: $(BINARIES)
#.DEFAULT_GOAL := all

clean_targets = $(OBJS) $(BINARIES) $(DEPS)

# Use secondary expansion for the dependencies here because we won't yet know
# the contents of clean_targets at this point.  Also, use wildcard so that we
# only run remove commands for those which exist.
clean: $$(addsuffix .clean,$$(wildcard $$(clean_targets)))
	$(at)-rm -f $(location_file)

# Do one target per removed file for ease of printing output.
%.clean:
	$(print_remove) rm -f $*

.PHONY: all clean
