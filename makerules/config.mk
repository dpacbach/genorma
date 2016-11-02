# Disable implicit rules
.SUFFIXES:

.DELETE_ON_ERROR:

.SECONDEXPANSION:

SHELL = /bin/bash

uname := $(shell /bin/uname)
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
    CFLAGS_DEBUG += -gstabs
    bin_platform = linux64
    soname_ld_option_prefix = -Wl,-soname,
    ld_no_undefined = -Wl,--no-undefined 
    bison_no_deprecated = -Wno-deprecated
endif
