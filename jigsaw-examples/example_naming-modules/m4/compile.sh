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
mkdir -p amlib2
mkdir -p amlib3
mkdir -p amlib4
mkdir -p classes

# Compile automatic modules first - they have no module-info.java
# Maven's Module Source Hierarchy cannot handle these, so we compile them manually
echo "=== Maven 4 Build (example_naming-modules) ==="
echo
echo "Step 1: Compile automatic modules manually"
echo

# Reset JAVA_HOME to compilation JDK if needed
COMPILE_JAVA_HOME="${JAVA_HOME}"
if [ -n "${JAVA11_HOME:-}" ] && [ "${JAVA11_HOME}" != "TODO/path/to/java11-jdk/goes/here" ]; then
  COMPILE_JAVA_HOME="${JAVA11_HOME}"
fi

# Compile automatic modules to separate amlib directories
counter=0
for dir in automatic-whatever automatic-whateverX-47.11 automatic-whateverX48.12 automatic-whateverX49-13
do
    counter=$((counter+1))
    echo "javac ${JAVAC_OPTIONS} -d classes/${dir} --release 11 \$(find ../src/${dir} -name \"*.java\")"
    # shellcheck disable=SC2046,SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting, the find command is intended to be expanded
    "${COMPILE_JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d classes/${dir} --release 11 $(find ../src/${dir} -name "*.java") 2>&1

    pushd classes/${dir} > /dev/null 2>&1
    echo "jar $JAR_OPTIONS --create --file=../../amlib${counter}/${dir}.jar ."
    # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
    "${COMPILE_JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../../amlib${counter}/${dir}.jar" . 2>&1
    popd >/dev/null 2>&1
done

# Now compile explicit modules with Maven
echo
echo "Step 2: Compile explicit modules with Maven 4"
echo

echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17, compiles for Java 11 via maven.compiler.release)"
mvn clean package


echo
echo "✅ Compilation complete"
echo "   Modular JARs: mlib/"
echo "   Automatic module JARs: amlib1/, amlib2/, amlib3/, amlib4/"
