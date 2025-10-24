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

echo "Running Java modules and capturing output..."

./run-main.sh 2>&1 | normalize > expected-result/run.txt
echo " " >> expected-result/run.txt
./run-mainbehindfacade.sh 2>&1 | normalize >> expected-result/run.txt

echo "✅ Expected result saved to expected-result/run.txt"
echo
echo "Contents:"
cat expected-result/run.txt
