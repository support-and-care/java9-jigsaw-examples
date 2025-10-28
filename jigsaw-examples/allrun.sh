#!/usr/bin/env bash
run() {
    MODDIR=${dir%*/}
    pushd "${MODDIR}" > /dev/null 2>&1 || exit
    # if any run*.sh script exists
    if  ls run*.sh > /dev/null 2>&1 ; then
        echo "###################################################################################################################################"
        for runscript in run*.sh 
        do
            echo "Running ${MODDIR}: ${runscript}"
            "./${runscript}"
        done
        echo
    fi
    popd >/dev/null 2>&1 || exit
}

for dir in example_*/;
do
    run
done
