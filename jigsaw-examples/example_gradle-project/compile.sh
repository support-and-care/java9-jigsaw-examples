#!/usr/bin/env bash
source ../env.sh

PATH="${JAVA17_HOME}/bin:$PATH"
JAVA_HOME=${JAVA17_HOME}

./gradlew --version
./gradlew --info --stacktrace --no-daemon build 2>&1

# copy JAR files from Gradle build to one single folder
rm -rf ./mlib
mkdir -p ./mlib
find mod* -type f -name "mod*.jar" -exec cp {} ./mlib \;
