#!/usr/bin/env bash
source ../env.sh

PATH="${JAVA17_HOME}/bin:$PATH"
JAVA_HOME=${JAVA17_HOME}

./gradlew --version
./gradlew --info --stacktrace --no-daemon clean 2>&1

rm -rf mlib/*.jar
mkdir -p mlib
