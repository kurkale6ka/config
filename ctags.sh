#!/bin/bash

# (?:abstract|final) doesn't work although it is an extended POSIX regex
# Two folders are taken into consideration in our example:

ctags -R --regex-PHP='/\s*abstract\s+class\s+(\w+)/\1/' --regex-PHP='/\s*final\s+class\s+(\w+)/\1/' --regex-PHP='/\s*interface\s+(\w+)/\1/' . /usr/share/php/
