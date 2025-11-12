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
if [ -n "${JAVA17_HOME:-}" ]; then
  export JAVA_HOME="${JAVA17_HOME}"
fi

# Add Maven 4 to PATH
export PATH="${M4_HOME}/bin:${PATH}"

mkdir -p mlib
mkdir -p patches
mkdir -p patchlib

echo "=== Step 1: Compile modules modmain and modb with Maven 4 ===="
echo
echo "mvn --version"
mvn --version
echo

echo "mvn clean compile"
mvn clean compile
echo

# Create JARs from Maven-compiled classes
echo "=== Step 2: Create module JARs ===="
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

# Compile the patch as classes, create (non-modular) jar.
#
# --patch-module modb=src/modb-patch/main/java: Treats patch sources (via symlink) as part of modb
# --module-path target/classes: Provides compiled modb classes for dependency resolution
# -d patches/modb: Compile output to directory patches/modb
# --release 11: Target Java 11 (matching the main modules)
# Source file: src/modb-patch/main/java/pkgb/B.java (symlink → ../../../../src/modb-patch)
echo "=== Step 3: Compile patch sources with javac ===="
echo "javac ${JAVAC_OPTIONS} --release 11 --patch-module modb=src/modb-patch/main/java --module-path target/classes -d patches/modb src/modb-patch/main/java/pkgb/B.java"
# shellcheck disable=SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} --release 11 --patch-module modb=src/modb-patch/main/java --module-path target/classes -d patches/modb src/modb-patch/main/java/pkgb/B.java 2>&1
echo

echo "=== Step 4: Create patch JAR ===="
pushd patches > /dev/null 2>&1
for dir in */;
do
  MODDIR=${dir%*/}
  echo "jar ${JAR_OPTIONS} --create --file=../patchlib/${MODDIR}.jar -C ${MODDIR} ."
  # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
  "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file="../patchlib/${MODDIR}.jar" -C "${MODDIR}" . 2>&1
done
popd >/dev/null 2>&1
echo

echo "✅ Compilation complete"
