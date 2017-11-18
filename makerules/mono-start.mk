# This is only used at the start of the mono build file.

true  := T
false :=

not = $(if $1,$(false),$(true))

Makefile  := $(lastword $(MAKEFILE_LIST))
root      := $(dir $(Makefile))

-include $(HOME)/.nr-make-rc.mk

CWD := $(root)

makerules := $(dir $(realpath $(Makefile)))
