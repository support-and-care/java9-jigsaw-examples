#!/usr/bin/env bash
source ../env.sh

PATH="${JAVA_HOME}/bin:$PATH"

./gradlew --version
./gradlew --info --stacktrace --no-daemon build 2>&1

# copy JAR files from Gradle build to one single folder
rm -rf ./mlib
mkdir -p ./mlib
find mod* -type f -name "mod*.jar" -exec cp {} ./mlib \;
