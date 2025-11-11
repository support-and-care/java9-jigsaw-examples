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
# Note: pom.xml uses source/target (not release) because --add-exports java.base
# is incompatible with --release flag
if [ -n "${JAVA17_HOME:-}" ]; then
  export JAVA_HOME="${JAVA17_HOME}"
fi

# Add Maven 4 to PATH
export PATH="${M4_HOME}/bin:${PATH}"

mkdir -p mlib

echo "mvn --version"
mvn --version
echo

echo "mvn clean compile"
echo "(Maven runs with JDK 17, targets Java 11 via maven.compiler.source/target)"
mvn clean compile

# Create JARs directly to mlib (similar to original compile.sh)
pushd target/classes > /dev/null 2>&1
for dir in */;
do
    MODDIR=${dir%*/}
    # Check if there's a custom MANIFEST.MF file for this module (via source symlink structure)
    if [ -f "../../src/${MODDIR}/main/java/META-INF/MANIFEST.MF" ]; then
        echo "jar $JAR_OPTIONS --create --manifest=../../src/${MODDIR}/main/java/META-INF/MANIFEST.MF --file=../../mlib/${MODDIR}.jar -C ${MODDIR} ."
        # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
        "${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --manifest="../../src/${MODDIR}/main/java/META-INF/MANIFEST.MF" --file="../../mlib/${MODDIR}.jar" -C "${MODDIR}" . 2>&1
    else
        echo "jar $JAR_OPTIONS --create --file=../../mlib/${MODDIR}.jar -C ${MODDIR} ."
        # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
        "${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../../mlib/${MODDIR}.jar" -C "${MODDIR}" . 2>&1
    fi
done
popd >/dev/null 2>&1
