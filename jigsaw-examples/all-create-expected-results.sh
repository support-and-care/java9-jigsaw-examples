#!/usr/bin/env bash
create_expected_result() {
    MODDIR=${dir%*/}
    pushd "${MODDIR}" > /dev/null 2>&1 || exit
    if [ -f ./create-expected-result.sh ]
    then
        echo "###################################################################################################################################"
        echo "Creating expected result for ${MODDIR}"
        ./create-expected-result.sh
        echo " "
    fi
    popd >/dev/null 2>&1 || exit
}

for dir in example_*/;
do
    create_expected_result
done