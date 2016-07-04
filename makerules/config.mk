# Disable implicit rules
.SUFFIXES:

CC := gcc

CFLAGS := -MMD -MP -std=c99
#CFLAGS_DEBUG   := -g -ggdb -gstabs
CFLAGS_DEBUG   := -g -ggdb
CFLAGS_RELEASE := -O2
CFLAGS_LIB     := -fPIC

ifdef OPT
    CFLAGS += $(CFLAGS_RELEASE)
else
    CFLAGS += $(CFLAGS_DEBUG)
endif

LD := gcc
LDFLAGS :=
LDFLAGS_LIB := -shared

INSTALL_PREFIX := $(HOME)/tmp

ifeq ($(OS),OSX)
    LIBXML2_LIB     := /usr/lib/libxml2.dylib
    LIBXML2_INCLUDE := /opt/local/include/libxml2
    CFLAGS          += -DOS_OSX
else
    LIBXML2_LIB     := /usr/lib64/libxml2.so
    LIBXML2_INCLUDE := /usr/include/libxml2
    CFLAGS          += -DOS_LINUX
endif

# This variable controls whether rule commands are echoed
# or suppressed infavor of more terse log output.
SHOW_RULES ?= YES
