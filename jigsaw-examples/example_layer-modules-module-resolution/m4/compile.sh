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

mkdir -p foomlib
mkdir -p barmlib

echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17, compiles for Java 11 via maven.compiler.release)"
mvn clean package

# Copy Maven-built JARs to layer-specific directories for dynamic module loading
echo
echo "Copying JARs to layer-specific directories..."

# Copy foo layer modules (modfoo, modversion1) to foomlib/
for mod in modfoo modversion1; do
    echo "cp target/example_layer-modules-module-resolution-m4-1.0-${mod}.jar foomlib/${mod}.jar"
    cp "target/example_layer-modules-module-resolution-m4-1.0-${mod}.jar" "foomlib/${mod}.jar"
done

# Copy bar layer modules (modbar, modversion2) to barmlib/
for mod in modbar modversion2; do
    echo "cp target/example_layer-modules-module-resolution-m4-1.0-${mod}.jar barmlib/${mod}.jar"
    cp "target/example_layer-modules-module-resolution-m4-1.0-${mod}.jar" "barmlib/${mod}.jar"
done

# Compile second version of modcommon from src2 (version 2.0)
# Maven doesn't support multiple versions of the same module, so we compile manually
echo
echo "Compiling modcommon v2.0 from src2..."
mkdir -p mods2

# Reset JAVA_HOME to compilation JDK if needed
COMPILE_JAVA_HOME="${JAVA_HOME}"
if [ -n "${JAVA11_HOME:-}" ]; then
  COMPILE_JAVA_HOME="${JAVA11_HOME}"
fi

echo "javac ${JAVAC_OPTIONS} -d mods2 --release 11 --module-version=2.0 --module-path target --module-source-path ../src2 \$(find ../src2/modcommon -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting, the find command is intended to be expanded
"${COMPILE_JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d mods2 --release 11 --module-version=2.0 --module-path target --module-source-path ../src2 $(find ../src2/modcommon -name "*.java") 2>&1

# Package new modcommon v2.0 as jar in barmlib (overwrites v1.0)
pushd mods2 > /dev/null 2>&1
echo "jar $JAR_OPTIONS --create --file=../barmlib/modcommon.jar -C modcommon ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${COMPILE_JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../barmlib/modcommon.jar" -C "modcommon" . 2>&1
popd >/dev/null 2>&1
