#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

# Create run-result directory if it doesn't exist
mkdir -p run-result

echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
    --module-path mlib${PATH_SEPARATOR}amlib1 \
    --add-modules modbar,modfoo \
    --module modmain/pkgmain.Main .  2>&1 | normalize | tee run-result/run.txt | myecho

