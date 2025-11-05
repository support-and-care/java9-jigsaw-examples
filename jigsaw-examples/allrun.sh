#!/usr/bin/env bash

set -eu -o pipefail

# Parse optional <type> parameter (e.g., "m4", "m3")
type="${1:-}"

# Arrays to track results
RAN=()
FAILED=()
SKIPPED=()

run() {
  MODDIR=${dir%*/}
  if [ -n "${type}" ]; then
    # Type-specific: example_xyz/m4/
    RUN_DIR="${MODDIR}/${type}"
  else
    # Default: example_xyz/
    RUN_DIR="${MODDIR}"
  fi

  if [ ! -d "${RUN_DIR}" ]; then
    SKIPPED+=("${MODDIR}${type:+/$type}")
    return
  fi

  pushd "${RUN_DIR}" >/dev/null 2>&1 || exit
  # if any run*.sh script exists
  if [ -x run.sh ]; then
    echo "###################################################################################################################################"
    echo "Running ${MODDIR}${type:+/$type}"
    if ./run.sh; then
      RAN+=("${MODDIR}${type:+/$type}")
    else
      FAILED+=("${MODDIR}${type:+/$type}")
    fi
    echo
  else
    SKIPPED+=("${MODDIR}${type:+/$type}")
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