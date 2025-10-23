#!/usr/bin/env bash
set -eu -o pipefail

EXAMPLE_NAME="$(basename "$(pwd)")"
EXPECTED="expected-result/run.txt"
ACTUAL="run-result/run.txt"

# Parse command line arguments
ONLY_VERIFY=false
if [ "${1:-}" = "--only" ]; then
  ONLY_VERIFY=true
fi

echo "=== Verifying ${EXAMPLE_NAME} ==="
echo

# Check if expected result exists
if [ ! -f "${EXPECTED}" ]; then
  echo "❌ ERROR: Expected result not found at ${EXPECTED}"
  echo "   Run ./create-expected-result.sh first to create the golden master"
  exit 1
fi

# Perform full build unless --only is specified
if [ "${ONLY_VERIFY}" = false ]; then
  echo "Step 1: Clean"
  ./clean.sh
  echo

  echo "Step 2: Compile"
  ./compile.sh
  echo

  echo "Step 3: Run and capture output"
  ./run.sh
  echo
else
  echo "Skipping clean and compile (--only mode)"
  echo

  # Check if actual result exists
  if [ ! -f "${ACTUAL}" ]; then
    echo "❌ ERROR: Actual result not found at ${ACTUAL}"
    echo "   Run ./run.sh first to generate the actual output"
    exit 1
  fi
fi

# Compare the files
echo "Step 4: Compare expected vs actual output"
if diff -ru "${EXPECTED}" "${ACTUAL}"; then
  echo
  echo "✅ SUCCESS: Output matches expected result"
  exit 0
else
  echo
  echo "❌ FAILURE: Output differs from expected result"
  echo "   Expected: ${EXPECTED}"
  echo "   Actual:   ${ACTUAL}"
  exit 1
fi
