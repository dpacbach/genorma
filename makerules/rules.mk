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

    NEW_L_SRCS     := $(wildcard $(relCWD)*.l)
    NEW_Y_SRCS     := $(wildcard $(relCWD)*.y)

    NEW_L_SRCS_CPP := $$(NEW_L_SRCS:.l=.l.cpp)
    NEW_Y_SRCS_CPP := $$(NEW_Y_SRCS:.y=.y.cpp)
    NEW_Y_SRCS_HPP := $$(NEW_Y_SRCS:.y=.y.hpp)

    NEW_L_SRCS_OBJ := $$(NEW_L_SRCS:.l=.l.o)

    NEW_C_SRCS   := $(wildcard $(relCWD)*.c)
    NEW_CPP_SRCS := $(wildcard $(relCWD)*.cpp) $$(NEW_L_SRCS_CPP) $$(NEW_Y_SRCS_CPP)

    # If there is a header file in the folder with the
    # special name then assume it will be a precompiled
    # header which will be compiled to an object file with
    # the extension .gch (on top of existing extension).
    NEW_PRECOMP  := $(wildcard $(relCWD)$(PRECOMP_NAME))
    INC_PRECOMP  := $$(if $$(NEW_PRECOMP),-Winvalid-pch -include $$(PRECOMP_NAME),)
    PRECOMP_GCH  := $$(if $$(NEW_PRECOMP),$$(NEW_PRECOMP).gch,)

    # It is possible that the cpp sources may contain duplicates if
    # a flex/bison generated cpp file is already in the directory.
    NEW_CPP_SRCS := $$(call uniq,$$(NEW_CPP_SRCS))

    NEW_OBJS_C   := $$(NEW_C_SRCS:.c=.o)
    NEW_OBJS_CPP := $$(NEW_CPP_SRCS:.cpp=.o)

    # For deps we don't need to distinguish between c/cpp
    NEW_DEPS     := $$(NEW_C_SRCS:.c=.d) $$(NEW_CPP_SRCS:.cpp=.d)
    ifneq ($$(NEW_PRECOMP),)
        NEW_DEPS := $$(NEW_DEPS) $$(NEW_PRECOMP).d
    endif

    C_SRCS      := $(C_SRCS)  $$(NEW_C_SRCS) $$(NEW_CPP_SRCS)
    YL_SRCS     := $(YL_SRCS) $$(NEW_L_SRCS_CPP) $$(NEW_Y_SRCS_CPP) $$(NEW_Y_SRCS_HPP)
    OBJS        := $(OBJS)    $$(NEW_OBJS_C) $$(NEW_OBJS_CPP)
    DEPS        := $(DEPS)    $$(NEW_DEPS)
    GCHS        := $(GCHS)    $$(PRECOMP_GCH)

    -include $$(NEW_DEPS)

    # Rule for running flex on a .l file.  The `sed` step is
    # to make a change that suppresses a warning.  This is
    # supposed to be corrected in more recent versions of flex,
    # so should probably be removed eventually.
    $$(NEW_L_SRCS_CPP): $(project_files)
    $$(NEW_L_SRCS_CPP): $(relCWD)%.l.cpp: $(relCWD)%.l
	    $$(print_flex) flex --posix -s -o $$@ -c $$<
    ifeq ($(OS),Linux)
	    $(at)sed -i.tmp 's/yy_size_t yy_buf_size/int yy_buf_size/' $$@
	    $(at)rm $$@.tmp
    endif
    # We cannot compile the flex-generated cpp until bison
    # runs and generates the hpp file.  It seems easiest to
    # to state this dependency to make using the cpp file.
    # Technically this is not exact, but seems fine since
    # the bison cpp and hpp files should go out of date
    # or become up to date together in normal usage.
    $$(NEW_L_SRCS_OBJ): $(relCWD)%.l.o: $(relCWD)%.y.cpp

    $$(NEW_Y_SRCS_CPP): $(project_files)
    $$(NEW_Y_SRCS_CPP): $(relCWD)%.y.cpp: $(relCWD)%.y
	    $$(print_bison) bison $(bison_no_deprecated) -d -o $$@ $$<

    # Here we put a static pattern rule otherwise when we run
    # make out of the folder containing this make file the
    # relCWD will be empty and so the pattern would match any
    # object file and cause this rule to be used to compile
    # files in other folders which is not correct.
    #
    # Note that in the rule below we are adding the project
    # file as an explicit dependency so as to cause all files
    # to be rebuilt if it changes (because usually changes to
    # this file would change a compiler flag or add a dependency
    # which would not otherwise trigger rebuilding.  We assume
    # that this file ends in a .mk extension and then filter
    # it out in the rule.
    $$(NEW_OBJS_C): $(project_files)
    $$(NEW_OBJS_C): $(relCWD)%.o: $(relCWD)%.c
	    $$(print_compile) $$(CC) $(TP_INCLUDES_$(LOCATION)) $(TP_INCLUDES_EXTRA) $(call include_flags,$(LOCATION)) $$($1) $(CXXFLAGS_TO_USE) -c $$< -o $$@

    # Note that we only support PCH for C++, and so we have
    # the dependency on the .gch file and also a -include flag
    # given to the compiler so that all sources in this folder
    # will include the pch header first.
    $$(NEW_OBJS_CPP): $(project_files) $$(PRECOMP_GCH)
    $$(NEW_OBJS_CPP): $(relCWD)%.o: $(relCWD)%.cpp
	    $$(print_compile) $$(CXX) $(TP_INCLUDES_$(LOCATION)) $(TP_INCLUDES_EXTRA) $(call include_flags,$(LOCATION)) $$(INC_PRECOMP) $$($1) $(CXXFLAGS_TO_USE) -c $$< -o $$@

    # If we're doing PCH then create a target that builds it.
    # Important: this compile rule should be kept identical to
    # the one above used to compile cpp files with the exception
    # that we don't have the pch-related flags here.
    ifneq ($$(NEW_PRECOMP),)
    $$(PRECOMP_GCH): $$(NEW_PRECOMP)
	    $$(print_compile) $$(CXX) $(TP_INCLUDES_$(LOCATION)) $(TP_INCLUDES_EXTRA) $(call include_flags,$(LOCATION)) $$($1) $(CXXFLAGS_TO_USE) -c $$< -o $$@
    endif

endef

compile_srcs_exe = $(eval $(call _compile_srcs,))
compile_srcs_so  = $(eval $(call _compile_srcs,CFLAGS_LIB))

################################################################################
# Linking binary
################################################################################
# In this function we use a hack to determine if we're linking an SO verses exe,
# and that is to check for the presence of a second parameter.
define _link

    OUT_NAME := $1

    $(LOCATION)_BINARY       := $(relCWD)$$(OUT_NAME)
    DEFAULT_GOAL_$(LOCATION) := $$($(LOCATION)_BINARY)

    NEW_L_SRCS     := $(wildcard $(relCWD)*.l)
    NEW_Y_SRCS     := $(wildcard $(relCWD)*.y)
    NEW_L_SRCS_CPP := $$(NEW_L_SRCS:.l=.l.cpp)
    NEW_Y_SRCS_CPP := $$(NEW_Y_SRCS:.y=.y.cpp)

    NEW_C_SRCS  := $(wildcard $(relCWD)*.c $(relCWD)*.cpp) $$(NEW_L_SRCS_CPP) $$(NEW_Y_SRCS_CPP)
    NEW_OBJS    := $$(NEW_C_SRCS:.cpp=.o)
    NEW_OBJS    := $$(NEW_OBJS:.c=.o)

    BINARIES    := $(BINARIES)    $$($(LOCATION)_BINARY)
    EXECUTABLES := $(EXECUTABLES) $$(if $2,,$$($(LOCATION)_BINARY))

    SONAME := $(soname_ld_option_prefix)$$(OUT_NAME)
    # Clear this string if we're not building an SO
    SONAME_$(LOCATION) := $$(if $2,$$(SONAME),)

    # Note that in the rule below we are adding the project
    # file as an explicit dependency so as to cause all files
    # to be rebuilt if it changes (because usually changes to
    # this file would change a compiler flag or add a dependency
    # which would not otherwise trigger rebuilding.  We assume
    # that this file ends in a .mk extension and then filter
    # it out in the rule.
    $(relCWD)$$(OUT_NAME): $(project_files)
    $(relCWD)$$(OUT_NAME): $$(NEW_OBJS) $(call link_binaries,$(LOCATION))
	    $$(print_link) $$(LD) $$($2) $(LDFLAGS) $$(SONAME_$(LOCATION)) $(ld_no_undefined) -Wl,-rpath,'$$$$ORIGIN' $$(call keep_link_files,$$^) $(TP_LINK_EXTRA) $(TP_LINK_$(LOCATION)) -o $$@

endef

link_exe = $(eval $(call _link,$1,))
link_so  = $(eval $(call _link,lib$1.$(SO_EXT),LDFLAGS_LIB))

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
