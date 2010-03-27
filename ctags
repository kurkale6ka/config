#! /usr/bin/env bash

# (?:abstract|final) doesn't work although it is an extended POSIX regex
# Two folders are taken into consideration in our example:

# tags generation for:
#
#     abstract|final     class     (class alone auto generated)
#       public|protected function  (private unnecessary)
#                        interface

ctags -R --regex-PHP='/\s*abstract\s+class\s+(\w+)/\1/'\
         --regex-PHP='/\s*final\s+class\s+(\w+)/\1/'\
         --regex-PHP='/\s*public\s+function\s+(\w+)/\1/'\
         --regex-PHP='/\s*protected\s+function\s+(\w+)/\1/'\
         --regex-PHP='/\s*interface\s+(\w+)/\1/'\
         --exclude='*~'\
         --exclude='dojo-release-1.4.1'\
         --exclude='static/conf'\
         --exclude='.svn' . /usr/share/php/
