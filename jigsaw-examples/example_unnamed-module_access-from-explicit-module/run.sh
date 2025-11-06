#!/usr/bin/env bash
source ../env.sh

# Show Java version for user information

result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"

echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo


# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
      --module-path mlib \
      --class-path cplib/cpb.jar \
      --module modmain/pkgmain.Main \
      2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho
