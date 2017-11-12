# This file will display some info about the various settings
# if the user sets the SHOW_CONFIG variable.
ifneq ($(origin SHOW_CONFIG),undefined)

gxx-version := $(shell $(CXX) -dumpfullversion)
$(info $(call output_using,g++ $(gxx-version)))

endif
