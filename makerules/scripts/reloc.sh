#!/bin/bash
# This bash script will simply find all of the auto-dependency
# files under the root and invoke a perl script on each one
# to adjust the relatives paths in the file to be relative to
# the new PWD.
SCRIPT_DIR=$(cd $(dirname $0) && pwd)
ROOT=$1
OLD_PWD=$2
NEW_PWD=$3
for f in $(find $ROOT -name "*.d"); do
    $SCRIPT_DIR/reloc.pl $NEW_PWD $OLD_PWD $f > $f.tmp || {
        echo "Error relocating $f!"
        # If there was an error in processing then file then
        # leave the tmp file for debugging and don't erase the
        # original.
        continue;
    }
    mv $f.tmp $f
done
