#!/usr/bin/env bash
compile() {
    MODDIR=${dir%*/}
    pushd "${MODDIR}" > /dev/null 2>&1 || exit
    if [ -f ./compile.sh ] 
    then 
        echo "###################################################################################################################################"
        echo "Compiling ${MODDIR}"
          if ! ./compile.sh; then
            echo "Could not compile '${MODDIR}' - this might lead to problems later!" >&2
          fi
        echo " "
    fi
    popd >/dev/null 2>&1 || exit
}

for dir in example_*/;
do
    compile
done
