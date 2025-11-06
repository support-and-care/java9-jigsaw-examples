#!/usr/bin/env bash
source ../env.sh


result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"

./apps_copyallexamples2appdir.sh

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo


# Aufruf des App-Servers
echo ""
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path "mlib${PATH_SEPARATOR}amlib" --module modstarter/pkgstarter.Starter . run-result --sync 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho
