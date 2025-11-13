#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# IMPORTANT: This example MUST run with JDK 11 (not JDK 17)
# The expected output was created with JDK 11, and the available modules list
# differs between JDK 11 and JDK 17.
if [ -z "${JAVA11_HOME:-}" ] || [ "${JAVA11_HOME}" = "TODO/path/to/java11-jdk/goes/here" ]; then
  echo "ERROR: This example requires JDK 11 to run (module list differs in JDK 17)"
  echo "Please set JAVA11_HOME in .envrc or env.sh"
  exit 1
fi

# Use JDK 11 for running (not the current JAVA_HOME which might be JDK 17)
export JAVA_HOME="${JAVA11_HOME}"

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create run-result directory if it doesn't exist
mkdir -p run-result

# Ensure mlib → target symlink exists and is valid
# (Java code uses ModuleLayer API to load modules from mlib/)
if [ -L mlib ] && [ ! -e mlib ]; then
  # Broken symlink, remove it
  rm mlib
fi
if [ ! -e mlib ]; then
  # Create symlink (target/ should exist from compile.sh)
  ln -s target mlib
fi

# Run the Java code with mlib on module-path
# Note: Automatic modules are not needed at runtime for this example
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
    --module-path target \
    --module modmain/pkgmain.Main . \
    2>&1 | normalize | tee run-result/run.txt | myecho
