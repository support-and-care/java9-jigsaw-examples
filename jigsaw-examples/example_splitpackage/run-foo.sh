#!/usr/bin/env bash
source ../env.sh

echo "Error: Does not run, as it does not even compile!"

# Module modmainfoo does not even compile
# "${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmainfoo/pkgmainfoo.Main 2>&1 | myecho
