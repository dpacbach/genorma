#####################################################################
# Error handling functions

assert_equal = $(call assert,$(call seq,$1,$2),$3)

undefined_error = $(error Error: make variable $1 must be defined)
assert_defined = $(if $(call seq,$(origin $1),undefined),$(call undefined_error,$1),)
