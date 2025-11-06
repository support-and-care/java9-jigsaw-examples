#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"


# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo


# Run the first Java command, save output to "${result_dir}/run.txt", and display with highlighting
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho

# Run the second Java command, append output to "${result_dir}/run.txt", and display with highlighting
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmainhidden.HiddenMain 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho
