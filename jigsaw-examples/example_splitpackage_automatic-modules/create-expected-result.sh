#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

EXAMPLE_NAME="$(basename "$(pwd)")"
echo "=== Creating expected result for ${EXAMPLE_NAME} ==="
echo

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create expected-result directory if it doesn't exist
mkdir -p expected-result

# Run the Java code and capture output
echo "Running Java module and capturing output..."
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
    --module-path mlib${PATH_SEPARATOR}amlib1 \
    --module modmain/pkgmain.Main .  2>&1 | tr -d '\r' > expected-result/run.txt

echo "✅ Expected result saved to expected-result/run.txt"
echo
echo "Contents:"
cat expected-result/run.txt
