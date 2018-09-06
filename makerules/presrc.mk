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
# Load  all  the  modules in nr-make that can be loaded before we
# load any project-specific config files  and traverse the source
# tree. Note that these need to be in a certain order
uname := $(shell uname)

include $(CWD)gmsl/gmsl
include $(CWD)clang.mk
include $(CWD)pre-config.mk
include $(CWD)utils.mk
include $(CWD)printing.mk
include $(CWD)error.mk
include $(CWD)reloc.mk
include $(CWD)locations.mk
include $(CWD)rules.mk
include $(CWD)dependencies.mk

# ===============================================================
# Standard top-level targets
build: $$(BINARIES)

# This  is a list of all binaries that we want to copy to the bin
# folder. Currently, we just  take  all  the top-level targets of
# each folder (e.g., exe, so) and filter out the archives,  since
# those don't need to be distributed to run. This  list  is  used
# both here (for defining the dependencies of  the  copy-bin  tar-
# get)  and also in another place to create the actual rules that
# do the copying. At this point  we  don't  know the list of bina-
# ries, so delay evaluation.
bins_to_copy = $(filter-out %.$(AR_EXT),$(BINARIES))

# If  run  as  a target this will build and copy all binaries. We
# use  second expansion here because we don't know what the BINA-
# RIES are at this point since the src tree hasn't been traversed
# yet.
copy-bin: $$(call map,to_bin_folder,$$(bins_to_copy))
# Does everything.
all: copy-bin

.DEFAULT_GOAL = all

# Build either debug or  release  specified  using make target in-
# stead  of make variable. -s means "quiet" so that make will not
# print  e.g.  "Entering  directory...". Note that if you run the
# debug target with OPT set then it  will  be  a  release  target
# which  defeats  the  purpose,  since  $(MAKE) will inherit that
# variable.  Also be careful here with race conditions with the
# .location file mechanism until that is fixed.
debug:
	@$(MAKE) -s all

release:
	@$(MAKE) -s all OPT=

# This target, apart from building  both  debug and release, will
# enable  building them both in parallel since they are specified
# as separate targets.
both: debug release

.PHONY: all build copy-bin both debug release

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

# -s tells make not to print "Entering/Leaving...".
clean-both:
	@$(MAKE) -s clean
	@$(MAKE) -s clean OPT=

.PHONY: clean clean-both

# Given A/B/C.cpp this will return A/B/X/C.cpp, where  X  is  the
# lib folder name, specific to the platform.
into_lib = $(dir $1)$(lib_name)/$(notdir $1)
