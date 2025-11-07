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

# Run the Java code with "." argument for dynamic layer creation, save output to run-result/run.txt, and display with highlighting
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${RUNTIME_JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main . 2>&1 | normalize | tee run-result/run.txt | myecho
