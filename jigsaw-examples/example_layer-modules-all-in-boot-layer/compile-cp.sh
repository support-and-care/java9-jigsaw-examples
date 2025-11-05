#!/usr/bin/env bash
source ../env.sh

MODNAME=modauto1
TARGET=amlib1

pushd src > /dev/null 2>&1 || exit
  
# compile as automatic module, i.e build an "ordinary", non-modular JAR file

echo "javac ${JAVAC_OPTIONS}   -d ../classes/${MODNAME}   \$(find ${MODNAME} -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../classes/${MODNAME}   $(find ${MODNAME} -name '*.java') 2>&1

echo "jar ${JAR_OPTIONS} --create --file=../${TARGET}/${MODNAME}.jar -C ../classes/${MODNAME} ."
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../${TARGET}/${MODNAME}.jar -C ../classes/${MODNAME} . 2>&1
  
popd > /dev/null 2>&1 || exit
