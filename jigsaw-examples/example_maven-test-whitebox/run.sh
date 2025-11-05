#!/usr/bin/env bash
source ../env.sh

# shellcheck disable=SC2086  # Variables in echo are for display only
echo "${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path target/lib${PATH_SEPARATOR}target/*.jar --module modmain/pkgmain.Main  2>&1 | myecho
# shellcheck disable=SC2086  # Option variables should not be quoted
# shellcheck disable=SC2086  # PATH_SEPARATOR must not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path target/lib${PATH_SEPARATOR}target/classes --module modmain/pkgmain.Main  2>&1 | myecho
