#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

# Create run-result directory if it doesn't exist
mkdir -p run-result

echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
      --module-path mlib \
      --class-path cplib/cpb.jar \
      --module modmain/pkgmain.Main \
      2>&1 | normalize | tee run-result/run.txt | myecho
