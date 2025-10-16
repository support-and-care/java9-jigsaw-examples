#!/usr/bin/env bash
clean() {
    MODDIR=${dir%*/}
    pushd "${MODDIR}" > /dev/null 2>&1 || exit
    if [ -f ./clean.sh ] 
    then 
        echo "###################################################################################################################################"
        echo "Cleaning ${MODDIR}"
        ./clean.sh
        echo " "
    fi
    popd >/dev/null 2>&1 || exit
}

source ./env.sh
"$JAVA_HOME/bin/java" --version

for dir in example_*/; 
do
    clean
done
