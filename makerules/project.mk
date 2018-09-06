# ===============================================================
# Default project settings
# ===============================================================
# In this module we set the base compiler flags that will be used
# for  compiling  all C/C++ files. If a library needs specific ad-
# ditions  to  these  flags  then they can specify them using the
# <location>.cflags  or  <location>.cxxflags in the library's own
# make file, where <location> is  the  location  name for that li-
# brary.
CFLAGS_BASE      := -MMD -MP -m64 -Wall -Wextra -pedantic

CFLAGS_DEBUG     := -g -ggdb
CFLAGS_RELEASE   := -O3

# Here  "not  specified" is defined as the `origin` of a variable
# being either "undefined" or  "default".  The  ?= operator would
# catch  the  former,  but  not  the latter. We need to catch the
# latter to prevent make from setting the variable to  a  default
# value  if it is undefined (in which case ?= won't then override
# it). In other words, the  only  values  we  want the below vari-
# ables to take are either  1)  a  value specified in the environ-
# ment or command line,  2)  a  value  that  we specify below. We
# don't want the default values that make gives them.
$(call set_if_not_specified,CC,gcc)
$(call set_if_not_specified,CXX,g++)
$(call set_if_not_specified,LD,g++)
$(call set_if_not_specified,AR,ar)

ifneq ($(OS),Windows)
    CFLAGS_LIB += -fPIC
    CFLAGS_AR  += -fPIC
endif

ifneq ($(origin OPT),undefined)
    CFLAGS += $(CFLAGS_BASE) $(CFLAGS_RELEASE)
else
    CFLAGS += $(CFLAGS_BASE) $(CFLAGS_DEBUG)
endif

# For C++ compilation we will (on the compile  command  line)  al-
# ready include the  C  flags,  so  CXXFLAGS  only includes those
# C++-specific flags that we need over  and  above  the  C  flags.
# Also, at the moment we  don't distinguish between debug/release
# (this is assumed to be done only in the C flags).
CXXFLAGS += # Allow user to add in their own on cmd line.

LDFLAGS     ?=
LDFLAGS_LIB := -shared

INSTALL_PREFIX := $(HOME)/tmp
