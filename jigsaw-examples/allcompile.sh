#!/usr/bin/env bash

set -eu -o pipefail

# Parse optional <type> parameter (e.g., "m4", "m3")
type="${1:-}"

# Arrays to track results
COMPILED=()
FAILED=()
SKIPPED=()

compile() {
  MODDIR=${dir%*/}
  if [ -n "${type}" ]; then
    # Type-specific: example_xyz/m4/
    COMPILE_DIR="${MODDIR}/${type}"
  else
    # Default: example_xyz/
    COMPILE_DIR="${MODDIR}"
  fi

  if [ ! -d "${COMPILE_DIR}" ]; then
    SKIPPED+=("${MODDIR}${type:+/$type}")
    return
  fi

  pushd "${COMPILE_DIR}" >/dev/null 2>&1 || exit
  if [ -f ./compile.sh ]; then
    echo "###################################################################################################################################"
    echo "Compiling ${MODDIR}${type:+/$type}"
    if ./compile.sh; then
      COMPILED+=("${MODDIR}${type:+/$type}")
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