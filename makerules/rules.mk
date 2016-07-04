################################################################################
# For clarity, the attempt in this file is to prefer eager evaluation within
# the "define" blocks when possible, and only use deferred evaluation (i.e.,
# the $$) when it is actually necessary.
################################################################################
# Setting location
################################################################################
define _set_location
    LOCATION := $1
    LOCATION_$$(LOCATION) := $(relCWD)
endef

set_location = $(eval $(call _set_location,$1))

################################################################################
# Compiling sources into object files
################################################################################
define _compile_srcs

    NEW_C_SRCS  := $(wildcard $(relCWD)*.cpp)
    NEW_OBJS    := $$(NEW_C_SRCS:.cpp=.o)
    NEW_DEPS    := $$(NEW_C_SRCS:.cpp=.d)

    C_SRCS      := $(C_SRCS) $$(NEW_C_SRCS)
    OBJS        := $(OBJS)   $$(NEW_OBJS)
    DEPS        := $(DEPS)   $$(NEW_DEPS)

    -include $$(NEW_DEPS)

    # Here we put a static pattern rule otherwise when
    # we run make out of the folder containing this make
    # file the relCWD will be empty and so the pattern
    # would match any object file and cause this rule
    # to be used to compile files in other folders which
    # is not correct.
    #
    # Note that the evaluation
    $$(NEW_OBJS): $(relCWD)%.o: $(relCWD)%.cpp
	    $$(print_compile) $$(CC) $(TP_INCLUDES_$(LOCATION)) $(call include_flags,$(LOCATION)) $$($1) $(CXXFLAGS_TO_USE) -c $$< -o $$@
endef

compile_srcs_exe = $(eval $(call _compile_srcs,))
compile_srcs_so  = $(eval $(call _compile_srcs,CFLAGS_LIB))

################################################################################
# Linking binary
################################################################################
define _link

    OUT_NAME := $1

    $(LOCATION)_BINARY       := $(relCWD)$$(OUT_NAME)
    DEFAULT_GOAL_$(LOCATION) := $$($(LOCATION)_BINARY)

    NEW_C_SRCS  := $(wildcard $(relCWD)*.cpp)
    NEW_OBJS    := $$(NEW_C_SRCS:.cpp=.o)

    BINARIES    := $(BINARIES)    $$($(LOCATION)_BINARY)
    EXECUTABLES := $(EXECUTABLES) $$(if $2,,$$($(LOCATION)_BINARY))

    $(relCWD)$$(OUT_NAME): $$(NEW_OBJS) $(call link_binaries,$(LOCATION))
	    $$(print_link) $$(LD) $$($2) $(LDFLAGS) $(TP_LINK_$(LOCATION)) $$^ -o $$@

endef

link_exe = $(eval $(call _link,$1,))
link_so  = $(eval $(call _link,lib$1.so,LDFLAGS_LIB))

################################################################################
# Highlevel functions
################################################################################
define _make_so
    $$(call set_location,$1)
    $$(call compile_srcs_so)
    $$(call link_so,$2)
endef

make_so = $(eval $(call _make_so,$1,$2))

define _make_exe
    $$(call set_location,$1)
    $$(call compile_srcs_exe)
    $$(call link_exe,$2)
endef

make_exe = $(eval $(call _make_exe,$1,$2))
