# ===============================================================
# Error handling functions

assert_equal = $(call assert,$(call seq,$1,$2),$3)

undefined_error = $(error Error: make variable $1 must be defined)
assert_defined = $(if $(call seq,$(origin $1),undefined),$(call undefined_error,$1),)
# Note  that  the argument to this function must be the name of a
# variable (because it is defererenced twice). This way both  the
# name and contents of the  variable  are known to this function.
assert_nonempty = $(call assert,$(strip $($(1))),variable $1 is empty but must not be so!)

# This will assert that there are  no  duplicates  in  the  list.
assert_no_dup = $(call assert,$(call leq,$1,$(call uniq,$1)),$2)
