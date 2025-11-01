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

./run-foo.sh 2>&1 | normalize | sed -e 's/\x1b\[[0-9;]*[mKGH]//g' -e 's/Package pkgbar in both.*/Package pkgbar in two different modules/g' > expected-result/run.txt
echo >> expected-result/run.txt
./run-bar.sh 2>&1 | normalize | sed -e 's/\x1b\[[0-9;]*[mKGH]//g' -e 's/Package pkgbar in both.*/Package pkgbar in two different modules/g' >> expected-result/run.txt

echo "✅ Expected result saved to expected-result/run.txt"
echo
echo "Contents:"
cat expected-result/run.txt
