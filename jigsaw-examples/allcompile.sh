#!/usr/bin/env bash

set -eu -o pipefail

# Arrays to track results
COMPILED=()
FAILED=()
SKIPPED=()

compile() {
  MODDIR=${dir%*/}
  pushd "${MODDIR}" >/dev/null 2>&1 || exit
  if [ -f ./compile.sh ]; then
    echo "###################################################################################################################################"
    echo "Compiling ${MODDIR}"
    if ./compile.sh; then
      COMPILED+=("${MODDIR}")
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
  compile
done

# Print summary
echo "###################################################################################################################################"
echo "=== Compilation Summary ==="
echo
echo "✅ Compiled: ${#COMPILED[@]}"
for example in "${COMPILED[@]}"; do
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
  echo "⊘ Skipped (no compile.sh): ${#SKIPPED[@]}"
  for example in "${SKIPPED[@]}"; do
    echo "   - ${example}"
  done
  echo
fi

# Exit with error if any failed
if [ ${#FAILED[@]} -gt 0 ]; then
  exit 1
fi