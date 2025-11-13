#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Use JDK 11 for runtime (required for javax.json automatic module)
if [ -z "${JAVA11_HOME:-}" ]; then
  echo "ERROR: JAVA11_HOME is not set. This example requires JDK 11 to run."
  exit 1
fi

# Create run-result directory if it doesn't exist
mkdir -p run-result

# Setup mlib for module-path access
# Windows: Copy JARs to mlib/ directory (symlinks cause AccessDeniedException)
# Unix: Use symlink to target/
if [ "${OS:-$(uname)}" = "Windows_NT" ]; then
  # Windows: Ensure mlib is a directory, copy JARs
  echo "We are on Windows, copying JARs to mlib/"
  rm -rf mlib
  mkdir -p mlib
  cp -p target/*.jar mlib/
  ls -l mlib/
else
  # Unix: Ensure mlib is a symlink to target
  echo "We are on Unix, using JARs from mlib/ as symlink"
  test -h mlib || ln -sfn target mlib
fi

echo "Using Java version:"
"${JAVA11_HOME}/bin/java" -version
echo

# Run the Java code, save output to run-result/run.txt, and display with highlighting
# The '.' argument specifies the JSON file (layers_triple_hierarchy.json) location
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA11_HOME}/bin/java" ${JAVA_OPTIONS} --module-path "target${PATH_SEPARATOR}amlib" --module mod.main/pkgmain.Main . 2>&1 | normalize | tee run-result/run.txt | myecho
