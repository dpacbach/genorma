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
    bin_platform = osx
else
    CFLAGS += -DOS_LINUX
    CFLAGS_DEBUG += -gstabs
    bin_platform = linux64
endif
