#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Use JDK 11 for runtime to ensure successful verification
RUNTIME_JAVA_HOME="${JAVA11_HOME}"

# Show Java version for user information
echo "Using Java version:"
"${RUNTIME_JAVA_HOME}/bin/java" -version
echo

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

# Run the Java code with "." argument for dynamic layer creation, save output to run-result/run.txt, and display with highlighting
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${RUNTIME_JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path target --module modmain/pkgmain.Main . 2>&1 | normalize | tee run-result/run.txt | myecho
