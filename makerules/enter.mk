# This is a special makefile that contains only the `enter' function
# used to traverse folders, setting the variable CWD with the name of
# the current folder (relative to the system's current working directory)
# upon entering each new folder.  This function is also used to enter
# into the makerules folder itself.
define enterimpl
    CWD_SP := $$(CWD_SP)_x
    $$(CWD_SP) := $$(CWD)
    CWD := $$(CWD)$1/
    #$$(info Entering $$(CWD))
    include $$(CWD)/makefile
    #$$(info Leaving $$(CWD))
    CWD := $$($$(CWD_SP))
    CWD_SP := $$(patsubst %_x,%,$$(CWD_SP))
endef

enter = $(eval $(call enterimpl,$1))

enter_all = $(call map,enter,$1)
