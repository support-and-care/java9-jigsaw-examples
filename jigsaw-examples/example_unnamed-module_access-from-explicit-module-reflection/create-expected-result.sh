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
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
      --module-path mlib \
      --class-path cplib/cpb.jar \
      --module modmain/pkgmain.Main \
      2>&1 | normalize > expected-result/run.txt

echo "✅ Expected result saved to expected-result/run.txt"
echo
echo "Contents:"
cat expected-result/run.txt
