# This is a make  file  for  producing  a  release package of the
# nr-make make system. It essentially  concatenates all the compo-
# nent make files into one large  one  and packages it with a few
# scripts that it needs, and tars it.

.DEFAULT_GOAL = all

this := $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))

input_files := $(wildcard makerules/*)

out-folder := mono-out
makerules  := makerules
out-make   := $(out-folder)/$(makerules)

out := $(out-make)/Makefile
tmp := $(out).tmp

$(out): $(input_files) $(this) | $(out-make)
	rm -f $(tmp)
	cat makerules/mono-start.mk   >>$(tmp)
	cat makerules/gmsl/__gmsl     >>$(tmp)
	cat makerules/pre-config.mk   >>$(tmp)
	cat makerules/utils.mk        >>$(tmp)
	cat makerules/printing.mk     >>$(tmp)
	cat makerules/error.mk        >>$(tmp)
	cat makerules/reloc.mk        >>$(tmp)
	cat makerules/locations.mk    >>$(tmp)
	cat makerules/rules.mk        >>$(tmp)
	cat makerules/dependencies.mk >>$(tmp)
	cat makerules/presrc.mk       >>$(tmp)
	cat makerules/project.mk      >>$(tmp)
	cat makerules/go.mk           >>$(tmp)
	cat makerules/post-config.mk  >>$(tmp)
	cat makerules/postsrc.mk      >>$(tmp)
	cat makerules/info.mk         >>$(tmp)
	sed -i '/^\(include .*\)/ d'    $(tmp)
	cp -f makerules/reloc.sh    $(out-make)
	cp -f makerules/reloc.pl    $(out-make)
	cp -f makerules/progress.sh $(out-make)
	cp -f nr-make               $(out-make)
	git log -1 --pretty=format:%H >$(out-make)/VERSION.txt
	mv $(tmp) $(out)

tar-name := mono-out.tar
tar := $(out-folder)/$(tar-name)

$(tar): $(out)
	cd $(out-folder) && tar cvf $(tar-name) $(makerules)

tar: $(tar)

all: $(tar)

clean:
	rm -rf $(out-folder)

.PHONY: all clean tar

$(out-make):
	mkdir -p $(out-make)
