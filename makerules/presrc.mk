# ===============================================================
# This is the `enter' function used  to traverse folders. It sets
# the variable CWD with the name of the current folder  (relative
# to  the  system's current working directory) upon entering each
# new folder. This function is also used to enter into the
# makerules folder itself.
define enterimpl
    CWD_SP := $$(CWD_SP)_x
    $$(CWD_SP) := $$(CWD)
    CWD := $$(CWD)$1/
    #$$(info Entering $$(CWD))
    include $$(CWD)/Makefile
    #$$(info Leaving $$(CWD))
    CWD := $$($$(CWD_SP))
    CWD_SP := $$(patsubst %_x,%,$$(CWD_SP))
endef

enter = $(eval $(call enterimpl,$1))
enter_all = $(call map,enter,$1)

# ===============================================================
# Traversal  of  makerules  and  source  tree.  Entering into the
# makerules folder will load all of  the makerules in that folder
# except for the ones explicitly loaded here.
include $(CWD)/makefile

# ===============================================================
# Standard top-level targets
build: $$(BINARIES)
# If  run  as  a target this will build and copy all binaries. We
# use  second expansion here because we don't know what the BINA-
# RIES are at this point since the src tree hasn't been traversed
# yet.
copy-bin: $$(call map,to_bin_folder,$$(BINARIES))
# Does everything.
all: copy-bin

.DEFAULT_GOAL = all

.PHONY: all build copy-bin

clean_targets = $(OBJS) $(BINARIES) $(DEPS) $(YL_SRCS) $(GCHS) \
                $(call map,to_bin_folder,$(BINARIES))

# Use secondary expansion for the dependencies  here  because  we
# won't yet know the contents of  clean_targets  at  this  point.
# Also, use wildcard so that we  only  run  remove  commands  for
# those which exist.
clean: $$(addsuffix .clean,$$(wildcard $$(clean_targets)))
	$(at)-rm -f $(location_file)

# Do one target per removed file for  ease  of  printing  output.
%.clean:
	$(print_remove) rm -f $*

.PHONY: clean

# Given A/B/C.cpp this will return A/B/X/C.cpp, where  X  is  the
# lib folder name, specific to the platform.
into_lib = $(dir $1)$(lib_name)/$(notdir $1)
