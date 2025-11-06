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

# This example runs two main classes in sequence
# 1. modmain/pkgmain.Main
# 2. modmainbehindfacade/pkgmainbehindfacade.MainBehindFacade

# Run first main class, save output to run-result/run.txt
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main 2>&1 | normalize | tee run-result/run.txt

# Add separator
echo " " | tee -a run-result/run.txt

# Run second main class, append output to run-result/run.txt
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmainbehindfacade/pkgmainbehindfacade.MainBehindFacade 2>&1 | normalize | tee -a run-result/run.txt | myecho
