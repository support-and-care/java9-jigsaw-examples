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


# --add-modules for both modb and modc is needed as otherwise a java.lang.NoClassDefFoundError is thrown because classes from modb/pkgb and modc/pkgc are not found
# because of the 'requires static' dependencies from modb->modc and modmain->modb, we need to add modb and modc explicitely to the runtime Configuration
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --add-modules modb,modc --module modmain/pkgmain.Main 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho
