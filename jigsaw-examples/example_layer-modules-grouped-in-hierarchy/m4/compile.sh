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
mkdir -p classes

# Ensure mlib → target symlink exists and is valid
# (Committed symlink works on Unix, but Windows needs it recreated after target/ exists)
mkdir -p target
if [ -L mlib ] && [ ! -e mlib ]; then
  # Broken symlink (target doesn't exist yet), remove it
  rm mlib
fi
if [ ! -e mlib ]; then
  # Create symlink (or recreate if it was broken)
  ln -s target mlib
fi

echo "=== Hybrid Compilation for Maven 4 ==="
echo
echo "Step 1: Manually compile automatic modules (modauto1, modauto2)"

# Function to compile automatic modules
function compileandjar() {
  mod="${1}"
  amlib="${2}"

  pushd ../src > /dev/null 2>&1

  # Compile as automatic module, i.e create an ordinary JAR file
  rm -rf ../m4/classes/"${mod}"
  mkdir -p ../m4/classes/"${mod}"

  echo "javac ${JAVAC_OPTIONS} -d ../m4/classes/${mod} --release 11 \$(find ${mod} -name \"*.java\")"
  # shellcheck disable=SC2046,SC2086  # find output needs word splitting, JAVAC_OPTIONS intentionally unquoted
  "${COMPILE_JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../m4/classes/"${mod}" --release 11 $(find "${mod}" -name "*.java") 2>&1

  echo "jar ${JAR_OPTIONS} --create --file=../m4/${amlib}/${mod}.jar -C ../m4/classes/${mod} ."
  # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
  "${COMPILE_JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../m4/"${amlib}"/"${mod}".jar -C ../m4/classes/"${mod}" . 2>&1

  popd > /dev/null 2>&1
}

compileandjar modauto1 amlib1
compileandjar modauto2 amlib2

echo
echo "Step 2: Maven compiles base modules (modcommon, modmain)"
echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17, compiles for Java 11 via maven.compiler.release)"
mvn clean package


echo
echo "Step 4: Manually compile modfoo (requires modauto1)"
pushd ../src/modfoo > /dev/null 2>&1
mkdir -p ../../m4/mods/modfoo
echo "javac ${JAVAC_OPTIONS} -d ../../m4/mods/modfoo --module-path ../../m4/target${PATH_SEPARATOR}../../m4/amlib1 --release 11 \$(find . -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # find output needs word splitting, JAVAC_OPTIONS intentionally unquoted
"${COMPILE_JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../../m4/mods/modfoo \
    --module-path ../../m4/target"${PATH_SEPARATOR}"../../m4/amlib1 \
    --release 11 \
    $(find . -name "*.java") 2>&1

echo "jar ${JAR_OPTIONS} --create --file=../../m4/target/modfoo.jar -C ../../m4/mods/modfoo ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${COMPILE_JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../../m4/target/modfoo.jar -C ../../m4/mods/modfoo . 2>&1
popd >/dev/null 2>&1

echo
echo "Step 5: Manually compile modbar (requires modauto2)"
pushd ../src/modbar > /dev/null 2>&1
mkdir -p ../../m4/mods/modbar
echo "javac ${JAVAC_OPTIONS} -d ../../m4/mods/modbar --module-path ../../m4/target${PATH_SEPARATOR}../../m4/amlib2 --release 11 \$(find . -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # find output needs word splitting, JAVAC_OPTIONS intentionally unquoted
"${COMPILE_JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../../m4/mods/modbar \
    --module-path ../../m4/target"${PATH_SEPARATOR}"../../m4/amlib2 \
    --release 11 \
    $(find . -name "*.java") 2>&1

echo "jar ${JAR_OPTIONS} --create --file=../../m4/target/modbar.jar -C ../../m4/mods/modbar ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${COMPILE_JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../../m4/target/modbar.jar -C ../../m4/mods/modbar . 2>&1
popd >/dev/null 2>&1

echo
echo "✅ Hybrid compilation complete"
