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
mkdir -p classes/cpb

echo "=== Hybrid Compilation for Maven 4 ==="
echo
echo "Step 1: Manually compile classpath code (cpb)"

# Compile cpb (classpath code) manually
pushd ../src > /dev/null 2>&1
echo "javac ${JAVAC_OPTIONS} -d ../m4/classes/cpb --release 25 \$(find cpb -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # find output needs word splitting, JAVAC_OPTIONS intentionally unquoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../m4/classes/cpb --release 25 $(find cpb -name "*.java") 2>&1

# Package cpb as JAR in cplib/
echo "jar ${JAR_OPTIONS} --create --file=../m4/cplib/cpb.jar -C ../m4/classes/cpb ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../m4/cplib/cpb.jar -C ../m4/classes/cpb . 2>&1
popd >/dev/null 2>&1

echo
echo "Step 2: Maven compiles explicit modules (modb, modmain)"
echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17+, compiles for Java 25 via maven.compiler.release)"
echo "(Compiler args: --add-reads modmain=ALL-UNNAMED --class-path cplib/cpb.jar)"
mvn clean package


echo
echo "✅ Hybrid compilation complete"
