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
-include $(project_files)
# If  this  project  contains multiple projects within subfolders
# then the above included project files  will  have  already  tra-
# versed the entire source tree  and  added  in at least one loca-
# tion. However, if either there are no project files or if those
# project files did not  descend  into  subolders  (i.e., if this
# project contains only one top-level folder with  source  files)
# then the list of locations  will  be  empty and no targets will
# have been created. In that case, for convenience, let's add  in
# a default target  for  convenience  that  simply  builds an exe-
# cutable  called  a.out  consisting of any source files found in
# the top-level folder, and we'll  also  copy  the binary file to
# this folder as well, but with a debug/opt suffix to distinguish
# those two.
ifeq ($(all_locations),)
    # Basic  minimal project with environment defaults. Creates a
    # single executable out of all the sources in  the  top-level
    # folder and that's it.
    $(call make_exe,MAIN,a.out$(opt-suffix))
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
