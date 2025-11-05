#!/usr/bin/env bash
source ../env.sh

function compileandjar() { 

pushd src > /dev/null 2>&1 || exit
  
  # compile as automatic module, i.e create an ordinary JAR file
  rm -rf ../classes/modauto*
  mkdir -p ../classes
  
  echo "javac ${JAVAC_OPTIONS}   -d ../classes/${1}   \$(find ${1} -name \"*.java\")"
  # shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
  "${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS} -d ../classes/${1}   $(find ${1} -name '*.java') 2>&1
  
  echo "jar ${JAR_OPTIONS} --create --file=../${2}/${1}.jar -C ../classes/${1} ."
  # shellcheck disable=SC2086  # Option variables should not be quoted
  "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../${2}/${1}.jar -C ../classes/${1} . 2>&1
  
popd > /dev/null 2>&1 || exit

}

compileandjar modauto1 amlib1
compileandjar modauto2 amlib2
