#!/usr/bin/env bash
source ../env.sh

mkdir -p mods
mkdir -p mlib 

echo "javac ${JAVAC_OPTIONS}  -d mods --module-path mlib --module-source-path src \$(find src -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS}  -d mods --module-path mlib --module-source-path src $(find src -name '*.java')  2>&1

# copy properties to mods dir (so that they are found for the JAR creation)
pushd src > /dev/null 2>&1 || exit
for dir in */; 
do
  find "${dir}" -type d -exec mkdir -p ../mods/{} \;
  find "${dir}" -name '*.properties' -exec cp -p -v {} ../mods/{} \;
done
popd >/dev/null 2>&1 || exit

pushd mods > /dev/null 2>&1 || exit
for dir in */; 
do
    MODDIR=${dir%*/}
    echo "jar ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} ."
    # shellcheck disable=SC2086  # Option variables should not be quoted
    "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} . 2>&1
done
popd >/dev/null 2>&1 || exit
