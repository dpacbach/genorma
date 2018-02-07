# This file contains config info that can only be  run  after  we
# have loaded any project-specific make files and/or traverse the
# source tree. It is the companion to pre-config.mk.
#
# Note that if any compile/link flags are set here that they need
# to have delayed expansion in the rules  (e.g.,  LDFLAGS  is  in-
# cluded on the linker command line as $$(LDFLAGS).

ifneq ($(origin STATIC_LIBSTDCXX),undefined)
    LDFLAGS += -static-libstdc++
endif

ifneq ($(origin STATIC_LIBGCC),undefined)
    LDFLAGS += -static-libgcc
endif

# If  on  Windows (and using MinGW) we have to add the bin folder
# into the PATH variable to get it to work properly.
ifeq ($(OS),Windows)
    PATH := $(PATH):$(dir $(CC))
endif
