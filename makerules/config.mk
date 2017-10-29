# Disable implicit rules
.SUFFIXES:

.DELETE_ON_ERROR:

.SECONDEXPANSION:

SHELL = /bin/bash

uname := $(shell uname)
valid_os = Darwin Linux

ifeq ($(filter $(uname),$(valid_os)),)
    $(error supported OS unames must be one of: $(valid_os))
endif

ifeq ($(uname),Darwin)
    OS := OSX
    CFLAGS += -DOS_OSX
    SO_EXT := dylib
    bin_platform = osx
    soname_ld_option_prefix = -Wl,-install_name,@loader_path/
    ld_no_undefined =
    bison_no_deprecated =
else
    OS := Linux
    CFLAGS += -DOS_LINUX
    SO_EXT := so
    bin_platform = linux64
    soname_ld_option_prefix = -Wl,-soname,
    ld_no_undefined = -Wl,--no-undefined 
    bison_no_deprecated = -Wno-deprecated
endif

PRECOMP_NAME := precomp.hpp

# Use this anytime we need to distinguish two  files  or  folders
# from the build output based on OPT status.
opt-suffix :=
ifneq ($(origin OPT),undefined)
    opt-suffix := .opt
endif

# This is the name that will  be  used for all the binary folders
# both in the source tree and at the top level.
lib_name := .lib-$(bin_platform)$(opt-suffix)
bin_name := bin-$(bin_platform)$(opt-suffix)

# There is one top-level bin folder per project. At least this is
# the default name unless it is overridden by the
# project-specific files.
bin_folder := $(root)$(bin_name)
