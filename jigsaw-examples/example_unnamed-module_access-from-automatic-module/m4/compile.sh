#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

mkdir -p cplib
mkdir -p amlib
mkdir -p classes

# This example contains NO explicit modules, only:
# - cpa: classpath code (no module-info.java)
# - modmain.auto: automatic module (no module-info.java)
# Both must be compiled manually as Maven's Module Source Hierarchy requires module descriptors

echo "=== Manual compilation (no Maven - no explicit modules) ==="
echo

# Step 1: Compile classpath code (cpa) first
echo "Step 1: Compile classpath code (cpa)"
pushd ../src > /dev/null 2>&1

dir=cpa
echo "javac ${JAVAC_OPTIONS} -d ../m4/classes/${dir} --release 25 \$(find ${dir} -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting, the find command is intended to be expanded
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../m4/classes/${dir} --release 25 $(find ${dir} -name "*.java") 2>&1

echo "jar $JAR_OPTIONS --create --file=../m4/cplib/${dir}.jar -C ../m4/classes/${dir} ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../m4/cplib/${dir}.jar" -C "../m4/classes/${dir}" . 2>&1

echo

# Step 2: Compile automatic module (modmain.auto) with access to classpath
echo "Step 2: Compile automatic module (modmain.auto)"
dir=modmain.auto
echo "javac ${JAVAC_OPTIONS} -cp ../m4/cplib/* -d ../m4/classes/${dir} --release 25 \$(find ${dir} -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting, the find command is intended to be expanded
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -cp ../m4/cplib/* -d ../m4/classes/${dir} --release 25 $(find ${dir} -name "*.java") 2>&1

echo "jar $JAR_OPTIONS --create --file=../m4/amlib/${dir}.jar -C ../m4/classes/${dir} ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../m4/amlib/${dir}.jar" -C "../m4/classes/${dir}" . 2>&1

popd >/dev/null 2>&1

echo
echo "✅ Compilation complete"
echo "   Classpath JAR: cplib/cpa.jar"
echo "   Automatic module JAR: amlib/modmain.auto.jar"
