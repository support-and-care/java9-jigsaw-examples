#!/usr/bin/env bash
source ../env.sh

function compileandjar() {
  mod="${1}"
  classes=classes${mod}
  modauto=modauto${mod}
  amlib=amlib${mod}

  pushd src > /dev/null 2>&1

  # compile as automatic module, i.e create an ordinary JAR file
  rm -rf ../${classes}
  mkdir -p ../${classes}
  
  echo "javac $JAVAC_OPTIONS   -d ../${classes}/modauto${mod}   \$(find ${modauto} -name \"*.java\")"
  $JAVA_HOME/bin/javac $JAVAC_OPTIONS -d ../${classes}   $(find ${modauto} -name "*.java") 2>&1
  
  echo "jar $JAR_OPTIONS --create --file=../${amlib}/${modauto}.jar -C ../${classes} ."
  $JAVA_HOME/bin/jar $JAR_OPTIONS --create --file=../${amlib}/${modauto}.jar -C ../${classes} . 2>&1
  
  popd > /dev/null 2>&1

}

compileandjar 1
compileandjar 2
