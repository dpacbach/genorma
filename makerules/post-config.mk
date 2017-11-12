# This file contains config info that can only be  run  after  we
# have loaded any project-specific make files and/or traverse the
# source tree. It is the companion to pre-config.mk.

ifneq ($(origin STATIC_LIBSTDCXX),undefined)
    LDFLAGS += -static-libstdc++
endif

ifneq ($(origin STATIC_LIBGCC),undefined)
    LDFLAGS += -static-libgcc
endif
