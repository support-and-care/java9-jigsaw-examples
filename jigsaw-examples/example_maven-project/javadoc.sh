#!/usr/bin/env bash
source ../env.sh

./mvnw --version --fail-at-end

cd src/moda
../../mvnw -s ../../mvn_settings.xml compile javadoc:javadoc --fail-at-end 2>&1
cd - >/dev/null 2>&1

cd src/modmain
../../mvnw -s ../../mvn_settings.xml compile javadoc:javadoc --fail-at-end 2>&1
cd - >/dev/null 2>&1
