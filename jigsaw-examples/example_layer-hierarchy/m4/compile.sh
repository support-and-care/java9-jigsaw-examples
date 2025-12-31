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

mkdir -p target/classes

# Note: mlib → target symlink is committed to Git
# It will be validated/recreated in run.sh after Maven compilation completes

# Step 1: Use Maven to download dependencies to amlib
echo "=== Step 1: Download dependencies with Maven ==="
echo
JAVA_HOME="${JAVA_HOME}" mvn --version
echo
echo "mvn initialize (copies javax.json to amlib/)"
JAVA_HOME="${JAVA_HOME}" mvn initialize
echo

# Step 2: Compile mod.x* modules first (to avoid split package conflict with javax.json)
# (see README: mod.x* must be compiled separately due to javax.json automatic module)
echo "=== Step 2: Compile mod.x* modules (separate compilation with javac) ==="
for modx in mod.x_bottom mod.x_middle mod.x_top
do
   echo "javac ${JAVAC_OPTIONS} --release 17 -d target/classes --module-path target${PATH_SEPARATOR}amlib --module-source-path \"src/*/main/java\" \$(find -L src/${modx}/main/java -name \"*.java\")"
   # shellcheck disable=SC2086  # JAVAC_OPTIONS is intentionally unquoted for word splitting
   # shellcheck disable=SC2046  # Word splitting intentional for multiple Java source files
   "${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} --release 17 -d target/classes \
       --module-path target${PATH_SEPARATOR}amlib \
       --module-source-path "src/*/main/java" \
       $(find -L src/${modx}/main/java -name "*.java") 2>&1
done
echo

# Step 3: Compile remaining 12 modules with Maven and create JARs
echo "=== Step 3: Compile remaining 12 modules with Maven and create JARs ==="
echo "mvn package"
JAVA_HOME="${JAVA_HOME}" mvn package
echo

# Step 4: Create JARs in target/ (for modules compiled with javac, Maven-compiled modules already have JARs)
echo "=== Step 4: Create module JARs for javac-compiled modules ==="
pushd target/classes > /dev/null 2>&1
for modx in mod.x_bottom mod.x_middle mod.x_top
do
    if [ -d "${modx}" ]; then
        echo "jar $JAR_OPTIONS --create --file=../${modx}.jar -C ${modx} ."
        # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
        "${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../${modx}.jar" -C "${modx}" . 2>&1
    fi
done
popd >/dev/null 2>&1
