# ===============================================================
# This will load most of the machinery in the make system
# ===============================================================
include $(CWD)/presrc.mk

# ===============================================================
# This will load the default settings for  a  project  which  the
# user can override in their own make files if they want.
# ===============================================================
include $(CWD)/project.mk

# ===============================================================
# Now invoke any user-defined project files -- this means any .mk
# files in the top-level folder of the project. If there are none
# then just assume a basic minimal project.
# ===============================================================
OLD_CWD := $(CWD)
CWD     := $(root)
project_files := $(wildcard $(root)*.mk $(root).*.mk)
ifneq ($(project_files),)
    include $(project_files)
else
    # Basic  minimal project with environment defaults. Creates a
    # single executable out of all the sources in  the  top-level
    # folder and that's it.
    $(call make_exe,MAIN,a.out)
    # Also in this case just dump the binary into the top  folder
    # instead of creating a binary folder for it.
    no_top_bin_folder = 1
    # Specify  that this is the location with the main executable
    # binary.
    main_is := MAIN
endif
CWD     := $(OLD_CWD)

# ===============================================================
# These are things that can only  be  done  after  the  project's
# source tree has been scanned.
# ===============================================================
include $(CWD)/postsrc.mk
