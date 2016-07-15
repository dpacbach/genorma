# Disable implicit rules
.SUFFIXES:

.DELETE_ON_ERROR:

.SECONDEXPANSION:

SHELL = /bin/bash

CC  ?= gcc
CXX ?= g++
LD  ?= gcc

valid_os = OSX Linux

ifeq ($(filter $(OS),$(valid_os)),)
    $(error the OS variable must be set to one of: $(valid_os))
endif

ifeq ($(OS),OSX)
    CFLAGS += -DOS_OSX
    SO_EXT := dylib
    bin_platform = osx
    soname_ld_option_prefix = -Wl,-install_name,@executable_path/
else
    CFLAGS += -DOS_LINUX
    SO_EXT := so
    CFLAGS_DEBUG += -gstabs
    bin_platform = linux64
    soname_ld_option_prefix = -Wl,-soname,
endif
