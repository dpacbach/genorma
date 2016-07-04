# This make file controls echoing/logging output during
# the make run.

c_red     := \033[31m
c_cyan    := \033[36m
c_green   := \033[32m
c_magenta := \033[35m
c_norm    := \033[00m

# This will colorize the "removed" part of the output of the
# rm command and will also remove the ticks.  We need to
# incoke the echo command here because apparently one cannot
# put escape sequences inside a seq string.
removed_red    := 's/removed/'`echo -e "$(c_red)"`'  removed'`echo -e "$(c_norm)"`'/'
remove_ticks   := 's/`//; s/'\''//'

ifdef V
    at :=
    print_rule :=
    colorize_clean :=
else
    at := @
    print_rule = @echo -e '$1' &&
    colorize_clean := | sed -r $(remove_ticks) | sed -r $(removed_red)
endif

print_compile = $(call print_rule,$(c_green)compiling$(c_norm) $<)
print_link    = $(call print_rule,  $(c_cyan)linking$(c_norm) $@)
print_run     = $(call print_rule,  running $@)
