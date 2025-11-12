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

# Run classpath code (cpmain) with access to module-path (modb)
# --add-modules modb makes the module available even though not required
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
        --module-path mlib \
        --class-path cplib/cpmain.jar"${PATH_SEPARATOR}"cplib/cpb.jar \
        --add-modules modb pkgcpmain.Main \
        2>&1 | normalize | tee run-result/run.txt | myecho
