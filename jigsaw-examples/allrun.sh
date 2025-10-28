#!/usr/bin/env bash

set -eu -o pipefail

run() {
    MODDIR=${dir%*/}
    pushd "${MODDIR}" > /dev/null 2>&1 || exit
    # if any run*.sh script exists
    if  [ -x run.sh ] ; then
        echo "###################################################################################################################################"
        echo "Running ${MODDIR}: run.sh"
        ./run.sh
        echo
    fi
    popd >/dev/null 2>&1 || exit
}

for dir in example_*/;
do
    run
done
