#!/usr/bin/env bash
source ../env.sh

mkdir -p mods
mkdir -p patches
mkdir -p mlib
mkdir -p patchlib

echo "javac ${JAVAC_OPTIONS}  -d mods --module-path mlib --module-source-path src \$(find src -name \"*.java\"|grep -v modb-patch)"
# shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS}  -d mods --module-path mlib --module-source-path src $(find src -name '*.java'|grep -v modb-patch) 2>&1

pushd mods > /dev/null 2>&1 || exit
for dir in */; 
do
    MODDIR=${dir%*/}
    echo "jar ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} ."
    # shellcheck disable=SC2086  # Option variables should not be quoted
    "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} . 2>&1
done
popd >/dev/null 2>&1 || exit

# Compile the patch as classes, create (non-modular) jar.
#
# --patch-module modb=src: Compile as if the source files were part of modb.
# -d patches/modb: Compile output to directory patches/modb

echo "javac ${JAVAC_OPTIONS}  --patch-module modb=src --module-path mods -d patches/modb src/modb-patch/pkgb/B.java"
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS}  --patch-module modb=src --module-path mods -d patches/modb src/modb-patch/pkgb/B.java  2>&1

pushd patches > /dev/null 2>&1 || exit
for dir in */;
do
  MODDIR=${dir%*/}
  echo "jar ${JAR_OPTIONS} --create --file=../patchlib/${MODDIR}.jar -C ${MODDIR} ."
  # shellcheck disable=SC2086  # Option variables should not be quoted
  "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../patchlib/${MODDIR}.jar -C ${MODDIR} . 2>&1
done
popd >/dev/null 2>&1 || exit
