#!/usr/bin/env bash
set -eu -o pipefail

EXAMPLE_NAME="$(basename "$(pwd)")"
EXPECTED="expected-result/run.txt"
ACTUAL="run-result/run.txt"

ONLY_VERIFY=false
if [ "${1:-}" = "--only" ]; then
  ONLY_VERIFY=true
fi

echo "=== Verifying ${EXAMPLE_NAME} ==="
echo

if [ ! -f "${EXPECTED}" ]; then
  echo "❌ ERROR: Expected result not found at ${EXPECTED}"
  exit 1
fi

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
  if [ ! -f "${ACTUAL}" ]; then
    echo "❌ ERROR: Actual result not found at ${ACTUAL}"
    exit 1
  fi
fi

echo "Step 4: Compare expected vs actual output"
if diff -u "${EXPECTED}" "${ACTUAL}"; then
  echo
  echo "✅ SUCCESS: Output matches expected result"
  exit 0
else
  echo
  echo "❌ FAILURE: Output differs from expected result"
  exit 1
fi
