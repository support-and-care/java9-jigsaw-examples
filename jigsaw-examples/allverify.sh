#!/usr/bin/env bash

set -eu -o pipefail

# Parse optional <type> parameter and other arguments
type=""
args=()
examples_dirs=()

# Parse arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        --*)
            # Flags starting with -- (e.g., --only)
            args+=("$1")
            shift
            ;;
        m4|m3|gradle-alt)
            # Type parameter (e.g., "m4", "m3")
            type="$1"
            shift
            ;;
        example_*)
            # Specific example names
            examples_dirs+=("$1/")
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# If no specific examples provided, use all examples
if [ "${#examples_dirs[@]}" -eq 0 ]; then
    examples_dirs=(example_*/)
fi

# Arrays to track results
VERIFIED=()
FAILED=()
SKIPPED=()

verify() {
  local verify_args=("$@")
  MODDIR=${dir%*/}

  if [ -n "${type}" ]; then
    # Type-specific: example_xyz/m4/
    VERIFY_DIR="${MODDIR}/${type}"
  else
    # Default: example_xyz/
    VERIFY_DIR="${MODDIR}"
  fi

  if [ ! -d "${VERIFY_DIR}" ]; then
    SKIPPED+=("${MODDIR}${type:+/$type}")
    return
  fi

  pushd "${VERIFY_DIR}" > /dev/null 2>&1 || exit
  if [ -f ./verify.sh ]
  then
    echo "###################################################################################################################################"
    echo "Verifying ${MODDIR}${type:+/$type}"
    if ./verify.sh "${verify_args[@]}"; then
      VERIFIED+=("${MODDIR}${type:+/$type}")
    else
      FAILED+=("${MODDIR}${type:+/$type}")
    fi
    echo " "
  else
    SKIPPED+=("${MODDIR}${type:+/$type}")
  fi
  popd >/dev/null 2>&1 || exit
}

echo "Verifying examples: ${examples_dirs[*]}${type:+ (type: $type)}"

for dir in "${examples_dirs[@]}";
do
    verify "${args[@]}"
done

# Print summary
echo "###################################################################################################################################"
echo "=== Verification Summary ==="
echo
echo "✅ Verified: ${#VERIFIED[@]}"
for example in "${VERIFIED[@]}"; do
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
    echo "⊘ Skipped (no verify.sh): ${#SKIPPED[@]}"
    for example in "${SKIPPED[@]}"; do
        echo "   - ${example}"
    done
    echo
fi

# Exit with error if any failed
if [ ${#FAILED[@]} -gt 0 ]; then
    exit 1
fi