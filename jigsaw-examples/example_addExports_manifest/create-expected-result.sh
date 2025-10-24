#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

EXAMPLE_NAME="$(basename "$(pwd)")"
echo "=== Creating expected result for ${EXAMPLE_NAME} ==="
echo

echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

mkdir -p expected-result

echo "Running Java module and capturing output..."

# Allow access to moda without using the "Add-Exports" entry from MANIFEST.MF
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
   --add-exports java.base/jdk.internal.misc=modmain \
   --add-exports moda/pkgainternal=modmain \
   --module-path mlib --module modmain/pkgmain.Main 2>&1 | normalize > expected-result/run.txt

# Allow access to moda with using the "Add-Exports" entry from MANIFEST.MF
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
   --add-modules moda \
   --module-path mlib \
   -jar mlib/modmain.jar 2>&1 | normalize >> expected-result/run.txt

echo "✅ Expected result saved to expected-result/run.txt"
echo
echo "Contents:"
cat expected-result/run.txt
