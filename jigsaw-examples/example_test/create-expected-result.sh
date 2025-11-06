#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

EXAMPLE_NAME="$(basename "$(pwd)")"
echo "=== Creating expected result for ${EXAMPLE_NAME} ==="
echo

echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

echo "Running example and capturing output..."
./run.sh expected-result

echo "✅ Expected result saved to expected-result/run.txt"
echo
echo "Contents:"
cat expected-result/run.txt
