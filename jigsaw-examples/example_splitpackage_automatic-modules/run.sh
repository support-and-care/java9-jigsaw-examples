#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

# Create run-result directory if it doesn't exist
mkdir -p run-result

echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

echo "Running the application with only modauto1 on the module path... "
echo

# when we run the application and only have amlib1/modauto1 on the module path,
#   we do not see an error, all is fine
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
    --module-path mlib${PATH_SEPARATOR}amlib1 \
    --module modmain/pkgmain.Main .  2>&1 | normalize | tee run-result/run.txt | myecho
