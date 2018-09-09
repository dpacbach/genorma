# This file contains logic that will be applied only if clang is
# being used as the compiler. We try to detect if the user has
# specified clang as the compiler and, if so, define the variable
# CLANG.

ifneq ($(filter %clang,$(CC)),)
  CLANG := 1
endif

ifdef CLANG
  # By default, a standard Linux build of clang on the system
  # will 1) use gcc's standard library, and 2) use the default
  # one on the system. Here, the user can specify that they want
  # clang to use the standard library (libstdc++) from a custom
  # build of gcc on the system.
  ifdef CLANG_USE_LIBSTDCXX
    # CLANG_USE_LIBSTDCXX should be the path to the folder whose name
	# is the gcc version.
    gcc-version  := $(patsubst gcc-%,%,$(notdir $(CLANG_USE_LIBSTDCXX)))
    gcc-version  := $(subst -,.,$(gcc-version))
    gcc-inc-home := $(CLANG_USE_LIBSTDCXX)/include/c++/$(gcc-version)
    gcc-lib-home := $(CLANG_USE_LIBSTDCXX)/lib64

    # There's an include folder within the gcc folder structure
    # with an architecture-dependent name. We must find it.
    ifeq ($(uname),Linux)
      gcc-inc-platform := $(gcc-inc-home)/x86_64-pc-linux-gnu
    else
    ifeq ($(uname),Darwin)
      # There is a version number of some kind in this folder
      # that may be hard to predict so let's use a wildcard.
      gcc-inc-platform := $(gcc-inc-home)/x86_64-apple-darwin*
      gcc-inc-platform := $(wildcard $(gcc-inc-platform))
    endif
    endif

    # Don't include the system header files.
    CXXFLAGS += -nostdinc++

    # Manually specify location of include folders and make sure
    # that we link the binary such that, at runtime, it will look
    # in the right place for libstdc++.
    CXXFLAGS += -I$(gcc-inc-home) -I$(gcc-inc-platform)
    ld-search-paths := -Wl,-rpath,$(gcc-lib-home) -L$(gcc-lib-home)
  endif
endif
