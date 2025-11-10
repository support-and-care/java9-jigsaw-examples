#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Ensure we're using Maven 4
if [ -z "${M4_HOME:-}" ]; then
  echo "ERROR: M4_HOME is not set. Please configure it in .envrc or env.sh"
  exit 1
fi

# Maven 4 requires Java 17+ to run, but we use JDK 11 for compilation
# Save JAVA17_HOME for Maven, restore JAVA_HOME for javac
MAVEN_JAVA_HOME="${JAVA17_HOME:-${JAVA_HOME}}"

# Add Maven 4 to PATH
export PATH="${M4_HOME}/bin:${PATH}"

mkdir -p mlib
mkdir -p target/classes

# Step 1: Use Maven to download dependencies to amlib
echo "=== Step 1: Download dependencies with Maven ==="
echo
JAVA_HOME="${MAVEN_JAVA_HOME}" mvn --version
echo
echo "mvn initialize (copies javax.json to amlib/)"
JAVA_HOME="${MAVEN_JAVA_HOME}" mvn initialize
echo

# Step 2: Compile mod.x* modules first (to avoid split package conflict with javax.json)
# (see README: mod.x* must be compiled separately due to javax.json automatic module)
echo "=== Step 2: Compile mod.x* modules (separate compilation with javac) ==="
for modx in mod.x_bottom mod.x_middle mod.x_top
do
   echo "javac ${JAVAC_OPTIONS} --release 11 -d target/classes --module-path mlib${PATH_SEPARATOR}amlib --module-source-path \"src/java/*/main\" \$(find -L src/java/${modx}/main -name \"*.java\")"
   # shellcheck disable=SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting
   "${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} --release 11 -d target/classes \
       --module-path mlib${PATH_SEPARATOR}amlib \
       --module-source-path "src/java/*/main" \
       $(find -L src/java/${modx}/main -name "*.java") 2>&1
done
echo

# Step 3: Compile remaining 12 modules with Maven (pom.xml lists all non-mod.x_* modules)
echo "=== Step 3: Compile remaining 12 modules with Maven compiler plugin ==="
echo "mvn compile"
JAVA_HOME="${MAVEN_JAVA_HOME}" mvn compile
echo

# Step 4: Create JARs
echo "=== Step 4: Create module JARs ==="
pushd target/classes > /dev/null 2>&1
for dir in */;
do
    MODDIR=${dir%*/}
    echo "jar $JAR_OPTIONS --create --file=../../mlib/${MODDIR}.jar -C ${MODDIR} ."
    # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
    "${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../../mlib/${MODDIR}.jar" -C "${MODDIR}" . 2>&1
done
popd >/dev/null 2>&1
