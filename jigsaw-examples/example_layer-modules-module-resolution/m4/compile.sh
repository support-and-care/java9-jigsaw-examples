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

mkdir -p mlib
mkdir -p foomlib
mkdir -p barmlib

echo "mvn --version"
mvn --version
echo

echo "mvn clean compile"
echo "(Maven runs with JDK 17, compiles for Java 11 via maven.compiler.release)"
mvn clean compile

# Create JARs in appropriate directories (matching original compile.sh structure)
pushd target/classes > /dev/null 2>&1

# Boot layer modules go to mlib
for mod in modcommon modmain;
do
    if [ -d "${mod}" ]; then
        echo "jar $JAR_OPTIONS --create --file=../../mlib/${mod}.jar -C ${mod} ."
        # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
        "${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../../mlib/${mod}.jar" -C "${mod}" . 2>&1
    fi
done

# Foo layer modules go to foomlib
for mod in modversion1 modfoo;
do
    if [ -d "${mod}" ]; then
        echo "jar $JAR_OPTIONS --create --file=../../foomlib/${mod}.jar -C ${mod} ."
        # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
        "${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../../foomlib/${mod}.jar" -C "${mod}" . 2>&1
    fi
done

# Bar layer modules go to barmlib
for mod in modversion2 modbar;
do
    if [ -d "${mod}" ]; then
        echo "jar $JAR_OPTIONS --create --file=../../barmlib/${mod}.jar -C ${mod} ."
        # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
        "${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../../barmlib/${mod}.jar" -C "${mod}" . 2>&1
    fi
done

popd >/dev/null 2>&1

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

echo "javac ${JAVAC_OPTIONS} -d mods2 --release 11 --module-version=2.0 --module-path mlib --module-source-path ../src2 \$(find ../src2/modcommon -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting, the find command is intended to be expanded
"${COMPILE_JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d mods2 --release 11 --module-version=2.0 --module-path mlib --module-source-path ../src2 $(find ../src2/modcommon -name "*.java") 2>&1

# Package new modcommon v2.0 as jar in barmlib (overwrites v1.0)
pushd mods2 > /dev/null 2>&1
echo "jar $JAR_OPTIONS --create --file=../barmlib/modcommon.jar -C modcommon ."
# shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
"${COMPILE_JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../barmlib/modcommon.jar" -C "modcommon" . 2>&1
popd >/dev/null 2>&1
