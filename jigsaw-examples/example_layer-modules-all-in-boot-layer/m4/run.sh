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

# Run the Java code with automatic module (modauto1) on module-path
# --add-modules ensures modbar and modfoo are resolved (otherwise they'd be unused)
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
    --module-path mlib"${PATH_SEPARATOR}"amlib1 \
    --add-modules modbar,modfoo \
    --module modmain/pkgmain.Main . \
    2>&1 | normalize | tee run-result/run.txt | myecho
