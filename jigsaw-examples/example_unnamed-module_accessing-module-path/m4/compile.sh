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

mkdir -p cplib
mkdir -p classes/cpb

# Step 1: Compile module (modb) first with Maven
echo
echo "Step 1: Compile module (modb) with Maven 4"
echo

echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17, compiles for Java 11 via maven.compiler.release)"
mvn clean package

# Step 2: Compile classpath code (cpb, cpmain) manually
# Maven's Module Source Hierarchy cannot handle this, so we compile it manually
echo
echo "Step 2: Compile classpath code (cpb, cpmain) manually"
echo

# Reset JAVA_HOME to compilation JDK if needed
COMPILE_JAVA_HOME="${JAVA_HOME}"
if [ -n "${JAVA11_HOME:-}" ] && [ "${JAVA11_HOME}" != "TODO/path/to/java11-jdk/goes/here" ]; then
  COMPILE_JAVA_HOME="${JAVA11_HOME}"
fi

# Compile classpath code in correct order: cpb first, then cpmain (which depends on cpb)
pushd ../src > /dev/null 2>&1
for dir in cpb cpmain;
do
    echo "javac ${JAVAC_OPTIONS} -cp ../m4/target/*${PATH_SEPARATOR}../m4/classes/cpb -d ../m4/classes/${dir} --release 11 \$(find ${dir} -name \"*.java\")"
    # shellcheck disable=SC2046,SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting, the find command is intended to be expanded
    "${COMPILE_JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -cp ../m4/target/*"${PATH_SEPARATOR}"../m4/classes/cpb -d ../m4/classes/${dir} --release 11 $(find ${dir} -name "*.java") 2>&1

    echo "jar $JAR_OPTIONS --create --file=../m4/cplib/${dir}.jar -C ../m4/classes/${dir} ."
    # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
    "${COMPILE_JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../m4/cplib/${dir}.jar" -C "../m4/classes/${dir}" . 2>&1
done
popd >/dev/null 2>&1
