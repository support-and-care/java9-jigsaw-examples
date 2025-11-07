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

echo "Running the application with only modauto1 on the module path... "
echo

# When we run the application and only have amlib1/modauto1 on the module path,
# we do not see an error, all is fine
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
    --module-path mlib"${PATH_SEPARATOR}"amlib1 \
    --module modmain/pkgmain.Main . \
    2>&1 | normalize | tee run-result/run.txt | myecho
