#!/usr/bin/env bash
source ../env.sh

PATH="${JAVA_HOME}/bin:$PATH"

./gradlew --version
./gradlew --info --stacktrace --no-daemon clean 2>&1

rm -rf mlib/*.jar
mkdir -p mlib
