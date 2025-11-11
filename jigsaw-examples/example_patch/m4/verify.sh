#!/usr/bin/env bash
set -eu -o pipefail

: "${TMPDIR:=/tmp}"

EXAMPLE_NAME="$(basename "$(dirname "$(pwd)")")"
echo "=== Verifying ${EXAMPLE_NAME} Maven 4 migration ==="

# Run the example (creates run-result/run.txt)
echo
echo "Step 1: Running example..."
./run.sh

# Compare with expected output
echo
echo "Step 2: Comparing with expected output..."
EXPECTED="../expected-result/run.txt"
ACTUAL="run-result/run.txt"

if [ ! -f "${EXPECTED}" ]; then
  echo "ERROR: Expected output file not found: ${EXPECTED}"
  exit 1
fi

if [ ! -f "${ACTUAL}" ]; then
  echo "ERROR: Actual output file not found: ${ACTUAL}"
  exit 1
fi

# Use diff to compare
DIFF_OUTPUT="${TMPDIR}/${EXAMPLE_NAME}-m4-diff.txt"
if diff -u "${EXPECTED}" "${ACTUAL}" > "${DIFF_OUTPUT}"; then
  echo "✅ Output matches expected result"
  rm -f "${DIFF_OUTPUT}"
  exit 0
else
  echo "❌ Output differs from expected result"
  echo
  echo "Differences:"
  cat "${DIFF_OUTPUT}"
  rm -f "${DIFF_OUTPUT}"
  exit 1
fi
