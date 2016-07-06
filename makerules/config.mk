# Disable implicit rules
.SUFFIXES:

.DELETE_ON_ERROR:

.SECONDEXPANSION:

SHELL = /bin/bash

CC  ?= gcc
CXX ?= g++
LD  ?= gcc
