#!/usr/bin/env bash

set -eu -o pipefail

# Arrays to track results
RAN=()
FAILED=()
SKIPPED=()

run() {
  MODDIR=${dir%*/}
  pushd "${MODDIR}" >/dev/null 2>&1 || exit
  # if any run*.sh script exists
  if [ -x run.sh ]; then
    echo "###################################################################################################################################"
    echo "Running ${MODDIR}"
    if ./run.sh; then
      RAN+=("${MODDIR}")
    else
      FAILED+=("${MODDIR}")
    fi
    echo
  else
    SKIPPED+=("${MODDIR}")
  fi
  popd >/dev/null 2>&1 || exit
}

for dir in example_*/; do
  run
done

# Print summary
echo "###################################################################################################################################"
echo "=== Run Summary ==="
echo
echo "✅ Ran: ${#RAN[@]}"
for example in "${RAN[@]}"; do
  echo "   - ${example}"
done
echo

if [ ${#FAILED[@]} -gt 0 ]; then
  echo "❌ Failed: ${#FAILED[@]}"
  for example in "${FAILED[@]}"; do
    echo "   - ${example}"
  done
  echo
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo "⊘ Skipped (no run.sh): ${#SKIPPED[@]}"
  for example in "${SKIPPED[@]}"; do
    echo "   - ${example}"
  done
  echo
fi

# Exit with error if any failed
if [ ${#FAILED[@]} -gt 0 ]; then
  exit 1
fi