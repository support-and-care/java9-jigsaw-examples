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
if [ -n "${JAVA17_HOME:-}" ]; then
  export JAVA_HOME="${JAVA17_HOME}"
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

# Reset JAVA_HOME to compilation JDK if needed
COMPILE_JAVA_HOME="${JAVA_HOME}"
if [ -n "${JAVA11_HOME:-}" ] && [ "${JAVA11_HOME}" != "TODO/path/to/java11-jdk/goes/here" ]; then
  COMPILE_JAVA_HOME="${JAVA11_HOME}"
fi

echo "javac ${JAVAC_OPTIONS} -d classes/modauto1 --release 11 \$(find ../src/modauto1 -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting, the find command is intended to be expanded
"${COMPILE_JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d classes/modauto1 --release 11 $(find ../src/modauto1 -name "*.java") 2>&1

# Package modauto1 as JAR in amlib1/ (automatic module library directory)
pushd classes/modauto1 > /dev/null 2>&1
echo "jar $JAR_OPTIONS --create --file=../../amlib1/modauto1.jar ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${COMPILE_JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../../amlib1/modauto1.jar" . 2>&1
popd >/dev/null 2>&1

# Now compile explicit modules with Maven
echo
echo "Step 2: Compile explicit modules (modbar, modcommon, modfoo, modmain) with Maven 4"
echo

echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17, compiles for Java 11 via maven.compiler.release)"
mvn clean package

