#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create run-result directory if it doesn't exist
mkdir -p run-result

# Run the first Java command, save output to run-result/run.txt, and display with highlighting
# JARs are now in target/ (created by maven-jar-plugin)
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path target --module modmain/pkgmain.Main 2>&1 | normalize | tee run-result/run.txt | myecho

# Run the second Java command, append output to run-result/run.txt, and display with highlighting
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path target --module modmain/pkgmainhidden.HiddenMain 2>&1 | normalize | tee -a run-result/run.txt | myecho
