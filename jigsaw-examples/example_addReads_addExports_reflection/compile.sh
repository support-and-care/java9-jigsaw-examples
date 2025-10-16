#!/usr/bin/env bash
source ../env.sh

mkdir -p mods
mkdir -p mlib

# compile modb
echo "javac $JAVAC_OPTIONS  -d mods --module-source-path src \$(find src/modb -name \"*.java\")"
$JAVA_HOME/bin/javac $JAVAC_OPTIONS  -d mods \
    --module-path mlib --module-source-path src $(find src/modb -name "*.java") \
     2>&1

# compile modmain (add-export of modb/pkgb -> modmain)
echo "javac $JAVAC_OPTIONS  -d mods --add-modules modb --add-exports modb/pkgb=modmain --add-reads modmain=modb --module-source-path src \$(find src/modmain -name \"*.java\")"
$JAVA_HOME/bin/javac $JAVAC_OPTIONS  -d mods \
    --add-modules modb \
    --add-exports modb/pkgb=modmain \
	--add-reads modmain=modb \
    --module-source-path src $(find src/modmain -name "*.java") \
     2>&1

pushd mods > /dev/null 2>&1
for dir in */; 
do
    MODDIR=${dir%*/}
    echo "jar $JAR_OPTIONS --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} ."
    $JAVA_HOME/bin/jar $JAR_OPTIONS --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} .  2>&1
done
popd >/dev/null 2>&1
