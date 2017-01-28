# ===============================================================
# Default project settings
# ===============================================================
CFLAGS         += -MMD -MP -m64 -Wall -Wextra -pedantic
CXXFLAGS       += $(CFLAGS)

CFLAGS_DEBUG   += $(CXXFLAGS) -g -ggdb
CFLAGS_RELEASE += $(CXXFLAGS) -Ofast

CC  := gcc
CXX := g++
LD  := g++

CFLAGS_LIB     += -fPIC

ifdef OPT
    CXXFLAGS_TO_USE = $(CFLAGS_RELEASE)
else
    CXXFLAGS_TO_USE = $(CFLAGS_DEBUG)
endif

LDFLAGS     :=
LDFLAGS_LIB := $(LDFLAGS) -shared 

INSTALL_PREFIX := $(HOME)/tmp
