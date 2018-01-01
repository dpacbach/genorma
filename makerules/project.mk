# ===============================================================
# Default project settings
# ===============================================================
CFLAGS         += -MMD -MP -m64 -Wall -Wextra -pedantic
CXXFLAGS       += $(CFLAGS)

CFLAGS_DEBUG   += $(CXXFLAGS) -g -ggdb
CFLAGS_RELEASE += $(CXXFLAGS) -O3

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
    CXXFLAGS_TO_USE = $(CFLAGS_RELEASE)
else
    CXXFLAGS_TO_USE = $(CFLAGS_DEBUG)
endif

LDFLAGS     ?=
LDFLAGS_LIB := -shared

INSTALL_PREFIX := $(HOME)/tmp
