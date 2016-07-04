# This module contains unit tests for the relPath function.
# It is meant to be run from the same folder as this file.

include ../gmsl/gmsl
include ../utils.mk

# test0
$(call assert_equal,$(call relPath, \
    a,                             \
    a                              \
),,test0 failed)
# test1
$(call assert_equal,$(call relPath, \
    a,                             \
    .                              \
),a,test1 failed)
# test2
$(call assert_equal,$(call relPath, \
    ./a,                           \
    .                              \
),a,test2 failed)
# test3
$(call assert_equal,$(call relPath, \
    ../a,                          \
    ../                            \
),a,test3 failed)
# test4
$(call assert_equal,$(call relPath, \
    ../a,                          \
    .                              \
),../a,test4 failed)
# test5
$(call assert_equal,$(call relPath, \
    a,                             \
    ../                            \
),test/a,test5 failed)
# test6
$(call assert_equal,$(call relPath, \
    a,                             \
    ../../                         \
),makerules/test/a,test6 failed)
# test7
$(call assert_equal,$(call relPath, \
    ../../../../a,                 \
    .                              \
),../../../../a,test7 failed)
# test8
$(call assert_equal,$(call relPath, \
    ../../../../a,                 \
    ../../../../                   \
),a,test8 failed)
# test9
$(call assert_equal,$(call relPath, \
    ../../../../a,                 \
    ../../                         \
),../../a,test9 failed)
# test10
$(call assert_equal,$(call relPath,        \
    ../../makerules/test/exesrc/makefile, \
    ../test/xyz/hello                     \
),../../exesrc/makefile,test10 failed)
# test11
$(call assert_equal,$(call relPath, \
    ../../makerules/b/c/d,         \
    ../b/c                         \
),d,test11 failed)

$(info All tests pass.)
