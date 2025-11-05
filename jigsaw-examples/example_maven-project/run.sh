#!/usr/bin/env bash
source ../env.sh

./mvnw --version --fail-at-end 2>&1

cd src/moda || exit
../../mvnw -B -s ../../mvn_settings.xml install 2>&1
cd - >/dev/null 2>&1 || exit

cd src/modmain || exit
../../mvnw -B -s ../../mvn_settings.xml test 2>&1
cd - >/dev/null 2>&1 || exit
