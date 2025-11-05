#!/usr/bin/env bash
source ../env.sh

mkdir -p mods
mkdir -p mlib

# compile moda
echo "javac ${JAVAC_OPTIONS}  -d mods --module-path mlib --module-source-path src \$(find src/moda -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS}  -d mods \
    --module-path mlib \
    --module-source-path src $(find src/moda -name '*.java') \
    2>&1

# create JAR file moda.jar
pushd mods > /dev/null 2>&1 || exit
MODDIR=moda
if [ -f "../src/${MODDIR}/META-INF/MANIFEST.MF" ]; then
  echo "jar ${JAR_OPTIONS} --create --manifest=../src/${MODDIR}/META-INF/MANIFEST.MF --file=../mlib/${MODDIR}.jar -C ${MODDIR} ."
  # shellcheck disable=SC2086  # Option variables should not be quoted
  "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --manifest=../src/${MODDIR}/META-INF/MANIFEST.MF --file=../mlib/${MODDIR}.jar -C ${MODDIR} . 2>&1
else
  echo "jar ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} ."
  # shellcheck disable=SC2086  # Option variables should not be quoted
  "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} . 2>&1
fi
popd >/dev/null 2>&1 || exit

# compile modmain
echo "javac ${JAVAC_OPTIONS}  -d mods --module-path mlib --module-source-path src \$(find src/modmain -name \"*.java\")"
# shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
"${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS}  -d mods \
    --module-path mlib \
    --add-exports java.base/jdk.internal.misc=modmain \
    --add-exports moda/pkgainternal=modmain \
    --module-source-path src $(find src/modmain -name '*.java')  \
    2>&1

# create JAR file modmain.jar
pushd mods > /dev/null 2>&1 || exit
MODDIR=modmain
if [ -f "../src/${MODDIR}/META-INF/MANIFEST.MF" ]; then
  echo "jar ${JAR_OPTIONS} --create --manifest=../src/${MODDIR}/META-INF/MANIFEST.MF --file=../mlib/${MODDIR}.jar -C ${MODDIR} ."
  # shellcheck disable=SC2086  # Option variables should not be quoted
  "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --manifest=../src/${MODDIR}/META-INF/MANIFEST.MF --file=../mlib/${MODDIR}.jar -C ${MODDIR} . 2>&1
else
  echo "jar ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} ."
  # shellcheck disable=SC2086  # Option variables should not be quoted
  "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} . 2>&1
fi
popd >/dev/null 2>&1 || exit
