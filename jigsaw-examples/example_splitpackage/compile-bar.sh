#!/usr/bin/env bash
source ../env.sh

mkdir -p mods
mkdir -p mlib 

echo "javac ${JAVAC_OPTIONS}  -d mods --module-path mlib --module-source-path src \$(find src/*bar* -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS}  -d mods --module-path mlib --module-source-path src $(find src/*bar* -name '*.java')  2>&1

pushd mods > /dev/null 2>&1 || exit
for dir in *bar*/; 
do
    MODDIR=${dir%*/}
    echo "jar ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} ."
    # shellcheck disable=SC2086  # Option variables should not be quoted
    "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} . 2>&1
done
popd >/dev/null 2>&1 || exit
