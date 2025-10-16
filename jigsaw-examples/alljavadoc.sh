#!/usr/bin/env bash
javadoc() {
    MODDIR=${dir%*/}
    pushd ${MODDIR} > /dev/null 2>&1
    if [ -f ./javadoc.sh ] 
    then 
        echo "###################################################################################################################################"
        echo "Generating JavaDoc in ${MODDIR}"
        ./javadoc.sh
        echo " "
    fi
    popd >/dev/null 2>&1 
}

source ./env.sh
$JAVA_HOME/bin/java --version

for dir in example_*/; 
do
    javadoc
done
