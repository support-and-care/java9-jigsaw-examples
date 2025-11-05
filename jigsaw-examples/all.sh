#!/usr/bin/env bash

set -eu -o pipefail

# Parse optional <type> parameter (e.g., "m4", "m3")
type="${1:-}"

all() {
    MODDIR=${dir%*/}
    if [ -n "${type}" ]; then
        # Type-specific: example_xyz/m4/
        ALL_DIR="${MODDIR}/${type}"
    else
        # Default: example_xyz/
        ALL_DIR="${MODDIR}"
    fi

    if [ ! -d "${ALL_DIR}" ]; then
        return
    fi

    pushd "${ALL_DIR}" > /dev/null 2>&1 || exit
    if [ -f ./all.sh ]
    then
        echo "###################################################################################################################################"
        echo "All in ${MODDIR}${type:+/$type}"
        ./all.sh
    elif [ -n "${type}" ]; then
        # For type-specific directories without all.sh, run individual scripts
        echo "###################################################################################################################################"
        echo "All in ${MODDIR}/${type} (clean, compile, run)"
        if [ -f ./clean.sh ]; then
            ./clean.sh
        fi
        if [ -f ./compile.sh ]; then
            ./compile.sh
        fi
        if [ -f ./run.sh ]; then
            ./run.sh
        fi
    fi
    popd >/dev/null 2>&1 || exit
    echo " "
}

for dir in example_*/;
do
    all
done
