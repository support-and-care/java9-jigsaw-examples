#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

mkdir -p mods
mkdir -p mlib

# Compile blackbox test module
echo "=== Step 4: Compile modtest.blackbox with javac ==="
echo "javac ${JAVAC_OPTIONS} -d mods --module-path amlib${PATH_SEPARATOR}mlib --module-source-path \"src/*/test/java\" \$(find src/modtest.blackbox/test/java/ -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d mods \
    --module-path amlib${PATH_SEPARATOR}mlib \
    --module-source-path "src/*/test/java" \
    $(find src/modtest.blackbox/test/java/ -name "*.java") 2>&1

# Package blackbox test JAR
echo "jar ${JAR_OPTIONS} --create --file=mlib/modtest.blackbox.jar -C mods/modtest.blackbox ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=mlib/modtest.blackbox.jar -C mods/modtest.blackbox . 2>&1
echo
