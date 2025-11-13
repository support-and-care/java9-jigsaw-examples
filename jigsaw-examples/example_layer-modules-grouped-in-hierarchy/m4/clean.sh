#!/usr/bin/env bash
rm -rf target
rm -rf amlib1
rm -rf amlib2
rm -rf classes
rm -rf mods
# Only remove mlib on Windows (where it's a directory with copied JARs)
# On Unix, mlib is a committed symlink and should remain
[ "${OS:-$(uname)}" = "Windows_NT" ] && rm -rf mlib
rm -rf run-result
