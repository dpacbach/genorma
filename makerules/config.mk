# Disable implicit rules
.SUFFIXES:

.DELETE_ON_ERROR:

SHELL = /bin/bash

CC  ?= gcc
CXX ?= g++
LD  ?= gcc
