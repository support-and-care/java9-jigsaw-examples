#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Ensure we're using Maven 4
if [ -z "${M4_HOME:-}" ]; then
  echo "ERROR: M4_HOME is not set. Please configure it in .envrc or env.sh"
  exit 1
fi

# Maven 4 requires Java 17+ to run
# Note: pom.xml has <maven.compiler.release>11</maven.compiler.release> which ensures
# Java 11 compatible bytecode even when using JDK 17 compiler with --release 11
MAVEN_JAVA_HOME="${JAVA17_HOME:-${JAVA_HOME}}"

# Add Maven 4 to PATH
export PATH="${M4_HOME}/bin:${PATH}"

mkdir -p mlib
mkdir -p amlib
mkdir -p patchlib

echo "=== Step 1: Show Maven version ==="
echo "mvn --version"
JAVA_HOME="${MAVEN_JAVA_HOME}" mvn --version
echo

echo "=== Step 2: Compile modfib with Maven and download JUnit ==="
echo "mvn clean test-compile"
echo "(Maven runs with JDK 17, compiles for Java 11 via maven.compiler.release)"
JAVA_HOME="${MAVEN_JAVA_HOME}" mvn clean test-compile
echo

# Create modfib JAR
echo "=== Step 3: Package modfib into mlib ==="
pushd target/classes > /dev/null 2>&1
for dir in */;
do
    MODDIR=${dir%*/}
    echo "jar ${JAR_OPTIONS} --create --file=../../mlib/${MODDIR}.jar -C ${MODDIR} ."
    # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
    "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file="../../mlib/${MODDIR}.jar" -C "${MODDIR}" . 2>&1
done
popd >/dev/null 2>&1
echo

# Prepare dependencies for whitebox test
JAVA_HOME="${MAVEN_JAVA_HOME}" mvn dependency:copy-dependencies -DoutputDirectory=amlib -DincludeScope=test

# Package whitebox test JAR
echo "jar ${JAR_OPTIONS} --create --file=patchlib/modfib.jar -C target/test-classes/modfib ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=patchlib/modfib.jar -C target/test-classes/modfib . 2>&1
echo
