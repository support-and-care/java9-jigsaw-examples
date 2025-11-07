#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Ensure we're using Maven 4
if [ -z "${M4_HOME:-}" ]; then
  echo "ERROR: M4_HOME is not set. Please configure it in .envrc or env.sh"
  exit 1
fi

# Determine which Java to use for compilation
COMPILE_JAVA_HOME="${JAVA_HOME}"
if [ -n "${JAVA11_HOME:-}" ] && [ "${JAVA11_HOME}" != "TODO/path/to/java11-jdk/goes/here" ]; then
  COMPILE_JAVA_HOME="${JAVA11_HOME}"
fi

# Maven 4 requires Java 17+ to run
# Note: pom.xml has <maven.compiler.release>11</maven.compiler.release> which ensures
# Java 11 compatible bytecode even when using JDK 17 compiler with --release 11
if [ -n "${JAVA17_HOME:-}" ]; then
  export JAVA_HOME="${JAVA17_HOME}"
fi

# Add Maven 4 to PATH
export PATH="${M4_HOME}/bin:${PATH}"

mkdir -p cplib
mkdir -p classes/cpmain
mkdir -p mlib

echo "=== Hybrid Compilation for Maven 4 ==="
echo
echo "Step 1: Maven compiles explicit modules (modb, modc)"
echo "mvn --version"
mvn --version
echo

echo "mvn clean compile"
echo "(Maven runs with JDK 17, compiles for Java 11 via maven.compiler.release)"
mvn clean compile

# Create JARs for modules
echo
echo "Step 2: Package modules as JARs in mlib/"
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
echo "Step 3: Manually compile classpath code (cpmain)"

# Compile cpmain (classpath code) with access to modules in mlib
pushd ../src > /dev/null 2>&1
echo "javac ${JAVAC_OPTIONS} -cp ../m4/mlib/*${PATH_SEPARATOR} -d ../m4/classes/cpmain --release 11 \$(find cpmain -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # find output needs word splitting, JAVAC_OPTIONS and PATH_SEPARATOR intentionally unquoted
"${COMPILE_JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} \
    -cp ../m4/mlib/*${PATH_SEPARATOR} \
    -d ../m4/classes/cpmain --release 11 \
    $(find cpmain -name "*.java") 2>&1

# Package cpmain as JAR in cplib/
echo "jar ${JAR_OPTIONS} --create --file=../m4/cplib/cpmain.jar -C ../m4/classes/cpmain ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${COMPILE_JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../m4/cplib/cpmain.jar -C ../m4/classes/cpmain . 2>&1
popd >/dev/null 2>&1

echo
echo "✅ Hybrid compilation complete"
