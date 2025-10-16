#!/usr/bin/env bash
source ../env.sh

# Logger using simple implementation
echo " "
echo "Using slf4j.simple as implementation for slf4j"

echo "$JAVA_HOME/bin/java $JAVA_OPTIONS --module-path mlib${PATH_SEPARATOR}amlib-api${PATH_SEPARATOR}amlib-simple --add-modules slf4j.simple --module modmain/pkgmain.Main | myecho"
$JAVA_HOME/bin/java $JAVA_OPTIONS \
    --module-path mlib${PATH_SEPARATOR}amlib-api${PATH_SEPARATOR}amlib-simple \
    --add-modules slf4j.simple \
    --module modmain/pkgmain.Main 2>&1 | myecho

