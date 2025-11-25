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

mkdir -p cplib
mkdir -p classes

# Compile classpath code (cpb) first - it has no module-info.java
# Maven's Module Source Hierarchy cannot handle this, so we compile it manually
echo
echo "Step 1: Compile classpath code (cpb) manually"
echo

echo "javac ${JAVAC_OPTIONS} -d classes --release 25 \$(find ../src/cpb -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting, the find command is intended to be expanded
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d classes --release 25 $(find ../src/cpb -name "*.java") 2>&1

# Package cpb as JAR in cplib/ (classpath library directory)
pushd classes > /dev/null 2>&1
echo "jar $JAR_OPTIONS --create --file=../cplib/cpb.jar ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../cplib/cpb.jar" . 2>&1
popd >/dev/null 2>&1

# Now compile modules with Maven
echo
echo "Step 2: Compile modules (modb, modmain) with Maven 4"
echo

echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17+, compiles for Java 25 via maven.compiler.release)"
echo "(Modules can access cpb on classpath via --add-reads modmain=ALL-UNNAMED)"
mvn clean package

