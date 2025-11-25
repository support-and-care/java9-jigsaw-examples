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
mkdir -p classes/cpmain

echo "=== Hybrid Compilation for Maven 4 ==="
echo
echo "Step 1: Maven compiles explicit modules (modb, modc)"
echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17+, compiles for Java 25 via maven.compiler.release)"
mvn clean package


echo
echo "Step 3: Manually compile classpath code (cpmain)"

# Compile cpmain (classpath code) with access to modules in mlib
pushd ../src > /dev/null 2>&1
echo "javac ${JAVAC_OPTIONS} -cp ../m4/mlib/*${PATH_SEPARATOR} -d ../m4/classes/cpmain --release 25 \$(find cpmain -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # find output needs word splitting, JAVAC_OPTIONS and PATH_SEPARATOR intentionally unquoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} \
    -cp ../m4/mlib/*${PATH_SEPARATOR} \
    -d ../m4/classes/cpmain --release 25 \
    $(find cpmain -name "*.java") 2>&1

# Package cpmain as JAR in cplib/
echo "jar ${JAR_OPTIONS} --create --file=../m4/cplib/cpmain.jar -C ../m4/classes/cpmain ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../m4/cplib/cpmain.jar -C ../m4/classes/cpmain . 2>&1
popd >/dev/null 2>&1

echo
echo "✅ Hybrid compilation complete"
