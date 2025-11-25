#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Ensure we're using Maven 4
if [ -z "${M4_HOME:-}" ]; then
  echo "ERROR: M4_HOME is not set. Please configure it in .envrc or env.sh"
  exit 1
fi

# Add Maven 4 to PATH
export PATH="${M4_HOME}/bin:${PATH}"

mkdir -p amlib1
mkdir -p classes

# Compile automatic module (modauto1) first - it has no module-info.java
# Maven's Module Source Hierarchy cannot handle this, so we compile it manually
echo
echo "Step 1: Compile automatic module (modauto1) manually"
echo

echo "javac ${JAVAC_OPTIONS} -d classes/modauto1 --release 25 \$(find ../src/modauto1 -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting, the find command is intended to be expanded
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d classes/modauto1 --release 25 $(find ../src/modauto1 -name "*.java") 2>&1

# Package modauto1 as JAR in amlib1/ (automatic module library directory)
pushd classes/modauto1 > /dev/null 2>&1
echo "jar $JAR_OPTIONS --create --file=../../amlib1/modauto1.jar ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../../amlib1/modauto1.jar" . 2>&1
popd >/dev/null 2>&1

# Now compile explicit modules with Maven
echo
echo "Step 2: Compile explicit modules (modbar, modcommon, modfoo, modmain) with Maven 4"
echo

echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17+, compiles for Java 25 via maven.compiler.release)"
mvn clean package

