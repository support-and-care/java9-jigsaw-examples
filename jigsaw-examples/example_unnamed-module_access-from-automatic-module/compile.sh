#!/usr/bin/env bash
source ../env.sh

mkdir -p amlib
mkdir -p classes
mkdir -p cplib

pushd src > /dev/null 2>&1

# create non-modular JAR cpa.jar to be put onto the classpath
export dir=cpa
echo "javac $JAVAC_OPTIONS   -d ../classes/${dir}   \$(find ${dir} -name \"*.java\")"
$JAVA_HOME/bin/javac $JAVAC_OPTIONS   -d ../classes/${dir}   $(find ${dir} -name "*.java") 2>&1

echo "jar $JAR_OPTIONS --create --file=../cplib/${dir}.jar -C ../classes/${dir} ."
$JAVA_HOME/bin/jar $JAR_OPTIONS --create --file=../cplib/${dir}.jar -C ../classes/${dir} . 2>&1

# --------------------------------------------------------------------------------------------------------------

# compile modmain.auto as automatic module, i.e create an ordinary JAR file
export dir=modmain.auto
echo "javac $JAVAC_OPTIONS   -d ../classes/${dir}   \$(find ${dir} -name \"*.java\")"
$JAVA_HOME/bin/javac $JAVAC_OPTIONS  -cp ../cplib/* -d ../classes/${dir}   $(find ${dir} -name "*.java") 2>&1

echo "jar $JAR_OPTIONS --create --file=../amlib/${dir}.jar -C ../classes/${dir} ."
$JAVA_HOME/bin/jar $JAR_OPTIONS --create --file=../amlib/${dir}.jar -C ../classes/${dir} . 2>&1

popd >/dev/null 2>&1
