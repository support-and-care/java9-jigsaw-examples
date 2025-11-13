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

mkdir -p amlib1
mkdir -p amlib2
mkdir -p classes1
mkdir -p classes2

echo "=== Hybrid Compilation for Maven 4 ==="
echo
echo "Step 1: Manually compile automatic modules (modauto1, modauto2)"

# Function to compile automatic modules
function compileandjar() {
  mod="${1}"
  classes=classes${mod}
  modauto=modauto${mod}
  amlib=amlib${mod}

  pushd ../src > /dev/null 2>&1

  # Compile as automatic module, i.e create an ordinary JAR file
  rm -rf ../m4/"${classes}"
  mkdir -p ../m4/"${classes}"

  echo "javac ${JAVAC_OPTIONS} -d ../m4/${classes} --release 11 \$(find ${modauto} -name \"*.java\")"
  # shellcheck disable=SC2046,SC2086  # find output needs word splitting, JAVAC_OPTIONS intentionally unquoted
  "${COMPILE_JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../m4/"${classes}" --release 11 $(find "${modauto}" -name "*.java") 2>&1

  echo "jar ${JAR_OPTIONS} --create --file=../m4/${amlib}/${modauto}.jar -C ../m4/${classes} ."
  # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
  "${COMPILE_JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../m4/"${amlib}"/"${modauto}".jar -C ../m4/"${classes}" . 2>&1

  popd > /dev/null 2>&1
}

compileandjar 1
compileandjar 2

echo
echo "Step 2: Maven compiles explicit module (modmain)"
echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17, compiles for Java 11 via maven.compiler.release)"
echo "(Compiler args: --module-path amlib1)"
mvn clean package


echo
echo "✅ Hybrid compilation complete"
