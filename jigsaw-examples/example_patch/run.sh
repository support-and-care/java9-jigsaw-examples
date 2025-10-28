#!/usr/bin/env bash
source ../env.sh

set -eu -o pipefail

result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main  2>&1 | normalize | tee ${result_dir}/run.txt | myecho

# Patch the module during startup, using a) exploded classes, b) a jar containing the patch.
#
# --patch-module modb=... does the patch (same option no matter if expoded classes or jar)

# Patch modb with classes
echo ">> Start modmain/pkgmain.Main with patch classes from patches/modb"
$JAVA_HOME/bin/java $JAVA_OPTIONS --patch-module modb=patches/modb --module-path mlib --module modmain/pkgmain.Main  2>&1 | normalize | tee -a ${result_dir}/run.txt | myecho

# Patch modb with a modular jar
echo ">> Start modmain/pkgmain.Main with patch classes from patchlib/modb.jar"
$JAVA_HOME/bin/java $JAVA_OPTIONS --patch-module modb=patchlib/modb.jar --module-path mlib --module modmain/pkgmain.Main  2>&1 | normalize | tee -a ${result_dir}/run.txt | myecho
