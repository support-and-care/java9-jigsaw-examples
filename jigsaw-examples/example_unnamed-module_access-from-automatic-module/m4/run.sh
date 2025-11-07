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

# Run automatic module (modmain.auto) with classpath code (cpa) on classpath
# The automatic module can access classpath code
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
    --module-path amlib \
    -cp cplib/cpa.jar \
    -m modmain.auto/pkgmain.Main \
    2>&1 | normalize | tee run-result/run.txt | myecho
