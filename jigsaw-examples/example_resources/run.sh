#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create run-result directory if it doesn't exist
mkdir -p run-result

# Run the Java code, save output to run-result/run.txt, and display with highlighting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main 2>&1 | normalize | tee run-result/run.txt | myecho
