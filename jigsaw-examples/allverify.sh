#!/usr/bin/env bash
set -eu -o pipefail

# Arrays to track results
VERIFIED=()
FAILED=()
SKIPPED=()

verify() {
    MODDIR=${dir%*/}
    pushd "${MODDIR}" > /dev/null 2>&1 || exit
    if [ -f ./verify.sh ]
    then
        echo "###################################################################################################################################"
        echo "Verifying ${MODDIR}"
        if ./verify.sh "$@"
        then
            VERIFIED+=("${MODDIR}")
        else
            FAILED+=("${MODDIR}")
        fi
        echo " "
    else
        SKIPPED+=("${MODDIR}")
    fi
    popd >/dev/null 2>&1 || exit
}

for dir in example_*/;
do
    verify "$@"
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