#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create run-result directory if it doesn't exist
mkdir -p run-result

# --add-modules for both modb and modc is needed as otherwise a java.lang.NoClassDefFoundError is thrown because classes from modb/pkgb and modc/pkgc are not found
# because of the 'requires static' dependencies from modb->modc and modmain->modb, we need to add modb and modc explicitely to the runtime Configuration
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --add-modules modb,modc --module modmain/pkgmain.Main 2>&1 | tr -d '\r' | tee run-result/run.txt | myecho
