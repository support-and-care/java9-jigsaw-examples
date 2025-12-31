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

# Compile automatic modules to separate amlib directories
counter=0
for dir in automatic-whatever automatic-whateverX-47.11 automatic-whateverX48.12 automatic-whateverX49-13
do
    counter=$((counter+1))
    echo "javac ${JAVAC_OPTIONS} -d classes/${dir} --release 17 \$(find ../src/${dir} -name \"*.java\")"
    # shellcheck disable=SC2046,SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting, the find command is intended to be expanded
    "${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d classes/${dir} --release 17 $(find ../src/${dir} -name "*.java") 2>&1

    pushd classes/${dir} > /dev/null 2>&1
    echo "jar $JAR_OPTIONS --create --file=../../amlib${counter}/${dir}.jar ."
    # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
    "${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../../amlib${counter}/${dir}.jar" . 2>&1
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
echo "(Maven runs with JDK 17+, compiles for Java 25 via maven.compiler.release)"
mvn clean package


echo
echo "✅ Compilation complete"
echo "   Modular JARs: mlib/"
echo "   Automatic module JARs: amlib1/, amlib2/, amlib3/, amlib4/"
