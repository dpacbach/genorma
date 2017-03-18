# ===============================================================
# This makefile is the driver for all nr-make projects.  All
# nr-make projects should create a symlink in their top-level
# folder (usually called `Makefile`) that links to this file, and
# the make system will take care of the rest.  Optionally, you
# can place additional files with .mk extensions in the top-level
# folder of your project and they will be detected and included
# at a place such that they are able to override most settings.
# ===============================================================
real_name := nr-make.mk
# The Makefile should be a symlink from the project's top-level
# folder to this file.
Makefile  := $(lastword $(MAKEFILE_LIST))
root      := $(dir $(Makefile))
makerules := $(dir $(realpath $(Makefile)))/makerules

# Make sure they aren't trying to run this make file directly.
ifeq ($(notdir $(Makefile)),$(real_name))
    $(error This file, $(real_name), should not be run directly)
endif

# ===============================================================
# This will load most of the machinery in the make system
# ===============================================================
CWD := $(makerules)/
include $(makerules)/go.mk
