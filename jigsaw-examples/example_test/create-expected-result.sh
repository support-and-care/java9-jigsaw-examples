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

echo "Running Java tests and capturing output..."

./run-blackboxtest.sh 2>&1 | normalize | sed 's/\x1b\[[0-9;]*[mKGH]//g' | grep -v "^Time: " > expected-result/run.txt
echo " " >> expected-result/run.txt
./run-whiteboxtest.sh 2>&1 | normalize | sed 's/\x1b\[[0-9;]*[mKGH]//g' | grep -v "^Time: " >> expected-result/run.txt
echo " " >> expected-result/run.txt
./run-whiteboxtest_with-optionsfile.sh 2>&1 | normalize | sed 's/\x1b\[[0-9;]*[mKGH]//g' | grep -v "^Time: " >> expected-result/run.txt

echo "✅ Expected result saved to expected-result/run.txt"
echo
echo "Contents:"
cat expected-result/run.txt
