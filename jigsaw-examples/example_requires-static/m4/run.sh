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

# --add-modules for both modb and modc is needed as otherwise a java.lang.NoClassDefFoundError is thrown
# because of the 'requires static' dependencies from modb->modc and modmain->modb,
# we need to add modb and modc explicitly to the runtime Configuration
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --add-modules modb,modc --module modmain/pkgmain.Main 2>&1 | normalize | tee run-result/run.txt | myecho
