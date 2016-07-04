# This make file controls echoing/logging output during
# the make run.

ifdef SHOW_RULES
    at =
    print_rule =
else
    at = @
    print_rule = @echo $1 &&
endif

print_compile = $(call print_rule,"compiling $<")
print_link    = $(call print_rule,"  linking $@")
print_run     = $(call print_rule,"  running $@")
