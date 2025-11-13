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

# Run the Java code, save output to run-result/run.txt, and display with highlighting
# note: not done here (but via api in modmain, see Main.java#26) as a replacement for --add-reads modmain=modb
# note: not done here (but via api in modmain, see Main.java#30) as a replacement for --add-exports modb/pkgbinternal=modmain
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path target \
     --add-modules modb \
     --add-exports modb/pkgb=modmain \
     --module modmain/pkgmain.Main 2>&1 | normalize | tee run-result/run.txt | myecho
