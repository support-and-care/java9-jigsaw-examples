#!/usr/bin/env bash

set -eu -o pipefail

# Parse optional <type> parameter (e.g., "m4", "m3")
type="${1:-}"

clean() {
    MODDIR=${dir%*/}
    if [ -n "${type}" ]; then
        # Type-specific: example_xyz/m4/
        CLEAN_DIR="${MODDIR}/${type}"
    else
        # Default: example_xyz/
        CLEAN_DIR="${MODDIR}"
    fi

    if [ ! -d "${CLEAN_DIR}" ]; then
        return
    fi

    pushd "${CLEAN_DIR}" > /dev/null 2>&1 || exit
    if [ -f ./clean.sh ]
    then
        echo "###################################################################################################################################"
        echo "Cleaning ${MODDIR}${type:+/$type}"
        ./clean.sh
        echo " "
    fi
    popd >/dev/null 2>&1 || exit
}

for dir in example_*/;
do
    clean
done
