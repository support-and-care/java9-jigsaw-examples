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

# Step 1: Compile module (modb) first with Maven
echo
echo "Step 1: Compile module (modb) with Maven 4"
echo

echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17+, compiles for Java 25 via maven.compiler.release)"
mvn clean package

# Step 2: Compile classpath code (cpb, cpmain) manually
# Maven's Module Source Hierarchy cannot handle this, so we compile it manually
echo
echo "Step 2: Compile classpath code (cpb, cpmain) manually"
echo

# Compile classpath code in correct order: cpb first, then cpmain (which depends on cpb)
pushd ../src > /dev/null 2>&1
for dir in cpb cpmain;
do
    echo "javac ${JAVAC_OPTIONS} -cp ../m4/target/*${PATH_SEPARATOR}../m4/classes/cpb -d ../m4/classes/${dir} --release 25 \$(find ${dir} -name \"*.java\")"
    # shellcheck disable=SC2046,SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting, the find command is intended to be expanded
    "${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -cp ../m4/target/*"${PATH_SEPARATOR}"../m4/classes/cpb -d ../m4/classes/${dir} --release 25 $(find ${dir} -name "*.java") 2>&1

    echo "jar $JAR_OPTIONS --create --file=../m4/cplib/${dir}.jar -C ../m4/classes/${dir} ."
    # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
    "${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../m4/cplib/${dir}.jar" -C "../m4/classes/${dir}" . 2>&1
done
popd >/dev/null 2>&1
