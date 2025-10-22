#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create run-result directory if it doesn't exist
mkdir -p run-result

# Run the first Java command, save output to run-result/run.txt, and display with highlighting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main 2>&1 | tr -d '\r' | tee run-result/run.txt | myecho

# Run the second Java command, append output to run-result/run.txt, and display with highlighting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmainhidden.HiddenMain 2>&1 | tr -d '\r' | tee -a run-result/run.txt | myecho
