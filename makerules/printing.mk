# This make file controls echoing/logging output during
# the make run.

c_red     := \033[31m
c_green   := \033[32m
c_yellow  := \033[33m
c_blue    := \033[34m
c_magenta := \033[35m
c_cyan    := \033[36m
c_norm    := \033[00m

ifneq (undefined, $(origin V))
    at :=
    print_rule :=
else
    at := @
    print_rule = @echo -e '$1' &&
endif

print_compile = $(call print_rule,$(c_green)compiling$(c_norm) $<)
print_link    = $(call print_rule,  $(c_cyan)linking$(c_norm) $@)
#print_run     = $(call print_rule,  $(c_blue)running$(c_norm) $<)
print_remove  = $(call print_rule, $(c_red)removing$(c_norm) $*)
print_copy    = $(call print_rule,  $(c_magenta)copying$(c_norm) $< to $(bin_folder))
print_copy_   = $(call print_rule,  $(c_magenta)copying$(c_norm) $$< to $(bin_folder))
print_mkdir   = $(call print_rule, $(c_magenta)creating$(c_norm) $@)
print_flex    = $(call print_rule,     $(c_yellow)flex$(c_norm) $<)
print_bison   = $(call print_rule,    $(c_yellow)bison$(c_norm) $<)
