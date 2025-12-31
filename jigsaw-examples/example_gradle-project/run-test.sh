#!/usr/bin/env bash
source ../env.sh

PATH="${JAVA_HOME}/bin:$PATH"

./gradlew --version
./gradlew --info --stacktrace --no-daemon test 2>&1
