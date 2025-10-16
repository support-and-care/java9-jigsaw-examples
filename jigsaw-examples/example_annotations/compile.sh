#!/usr/bin/env bash
source ../env.sh

mkdir -p mods
mkdir -p mlib 

echo "javac $JAVAC_OPTIONS  -d mods --module-path mlib --module-source-path src \$(find src -name \"*.java\")"
$JAVA_HOME/bin/javac $JAVAC_OPTIONS  -d mods --module-path mlib --add-modules mod.annotations --module-source-path src $(find src -name "*.java")  2>&1

pushd mods > /dev/null 2>&1
for dir in */; 
do
    MODDIR=${dir%*/}
    echo "jar $JAR_OPTIONS --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} ."
    $JAVA_HOME/bin/jar $JAR_OPTIONS --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} .  2>&1
done
popd >/dev/null 2>&1
