#!/usr/bin/env bash
source ../env.sh

mkdir -p mods
mkdir -p mlib
mkdir -p classes/cpb
mkdir -p cplib

#  create non-modular jars to be put onto the classpath
pushd src > /dev/null 2>&1 || exit

for dir in cpb;
do
   echo "javac ${JAVAC_OPTIONS} -d ../classes/${dir} \$(find ${dir} -name \"*.java\")"
   # shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
   "${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../classes/${dir} $(find ${dir} -name '*.java') 2>&1

   echo "jar ${JAR_OPTIONS} --create --file=../cplib/${dir}.jar -C ../classes/${dir} ."
   # shellcheck disable=SC2086  # Option variables should not be quoted
   "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../cplib/${dir}.jar -C ../classes/${dir} . 2>&1
done
popd >/dev/null 2>&1 || exit

