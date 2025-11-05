#!/usr/bin/env bash
source ../env.sh

mkdir -p mods
mkdir -p mlib
mkdir -p classes/cpb
mkdir -p cplib

echo "javac ${JAVAC_OPTIONS}  -d mods --add-reads modmain=ALL-UNNAMED --class-path cplib/cpb.jar --module-path mlib${PATH_SEPARATOR}cplib --module-source-path src \$(find src -name \"*.java\"| grep -v cp)"
# shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} \
      -d mods \
	  --add-reads modmain=ALL-UNNAMED \
      --class-path cplib/cpb.jar \
	  --module-path mlib${PATH_SEPARATOR}cplib \
      --module-source-path src $(find src -name "*.java"| grep -v cp) \
      2>&1

pushd mods > /dev/null 2>&1 || exit
for dir in */; 
do
    MODDIR=${dir%*/}
    echo "jar ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} ."
    # shellcheck disable=SC2086  # Option variables should not be quoted
    "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} . 2>&1
done
popd >/dev/null 2>&1 || exit
