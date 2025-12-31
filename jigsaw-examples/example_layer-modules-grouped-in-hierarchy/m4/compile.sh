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
mkdir -p classes

# Note: mlib → target symlink is committed to Git
# It will be validated/recreated in run.sh after Maven compilation completes

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

  echo "javac ${JAVAC_OPTIONS} -d ../m4/classes/${mod} --release 17 \$(find ${mod} -name \"*.java\")"
  # shellcheck disable=SC2046,SC2086  # find output needs word splitting, JAVAC_OPTIONS intentionally unquoted
  "${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../m4/classes/"${mod}" --release 17 $(find "${mod}" -name "*.java") 2>&1

  echo "jar ${JAR_OPTIONS} --create --file=../m4/${amlib}/${mod}.jar -C ../m4/classes/${mod} ."
  # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
  "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../m4/"${amlib}"/"${mod}".jar -C ../m4/classes/"${mod}" . 2>&1

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
echo "(Maven runs with JDK 17+, compiles for Java 25 via maven.compiler.release)"
mvn clean package


echo
echo "Step 4: Manually compile modfoo (requires modauto1)"
pushd ../src/modfoo > /dev/null 2>&1
mkdir -p ../../m4/mods/modfoo
echo "javac ${JAVAC_OPTIONS} -d ../../m4/mods/modfoo --module-path ../../m4/target${PATH_SEPARATOR}../../m4/amlib1 --release 17 \$(find . -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # find output needs word splitting, JAVAC_OPTIONS intentionally unquoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../../m4/mods/modfoo \
    --module-path ../../m4/target"${PATH_SEPARATOR}"../../m4/amlib1 \
    --release 17 \
    $(find . -name "*.java") 2>&1

echo "jar ${JAR_OPTIONS} --create --file=../../m4/target/modfoo.jar -C ../../m4/mods/modfoo ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../../m4/target/modfoo.jar -C ../../m4/mods/modfoo . 2>&1
popd >/dev/null 2>&1

echo
echo "Step 5: Manually compile modbar (requires modauto2)"
pushd ../src/modbar > /dev/null 2>&1
mkdir -p ../../m4/mods/modbar
echo "javac ${JAVAC_OPTIONS} -d ../../m4/mods/modbar --module-path ../../m4/target${PATH_SEPARATOR}../../m4/amlib2 --release 17 \$(find . -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # find output needs word splitting, JAVAC_OPTIONS intentionally unquoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../../m4/mods/modbar \
    --module-path ../../m4/target"${PATH_SEPARATOR}"../../m4/amlib2 \
    --release 17 \
    $(find . -name "*.java") 2>&1

echo "jar ${JAR_OPTIONS} --create --file=../../m4/target/modbar.jar -C ../../m4/mods/modbar ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../../m4/target/modbar.jar -C ../../m4/mods/modbar . 2>&1
popd >/dev/null 2>&1

echo
echo "✅ Hybrid compilation complete"
