#!/usr/bin/env bash
source ../env.sh

echo ""
$JAVA_HOME/bin/java $JAVA_OPTIONS --module-path "mlib${PATH_SEPARATOR}amlib" --module mod.main/pkgmain.Main .  2>&1 | myecho

