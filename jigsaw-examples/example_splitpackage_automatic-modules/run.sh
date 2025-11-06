#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"



echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

echo "Running the application with only modauto1 on the module path... "
echo

# when we run the application and only have amlib1/modauto1 on the module path,
#   we do not see an error, all is fine
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
    --module-path mlib${PATH_SEPARATOR}amlib1 \
    --module modmain/pkgmain.Main .  2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho
