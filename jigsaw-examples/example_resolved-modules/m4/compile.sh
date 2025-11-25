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

mkdir -p mlib

echo "mvn --version"
mvn --version
echo

echo "mvn clean package"
echo "(Maven runs with JDK 17+, compiles for Java 25 via maven.compiler.release)"
mvn clean package

# Copy JARs to mlib with simple names for jlink
# (jlink outputs the JAR filename in its output, and we need simple names)
echo
echo "Copying JARs to mlib with simple names..."
for mod in moda modb modc; do
    echo "cp target/example_resolved-modules-m4-1.0-SNAPSHOT-${mod}.jar mlib/${mod}.jar"
    cp "target/example_resolved-modules-m4-1.0-SNAPSHOT-${mod}.jar" "mlib/${mod}.jar"
done

