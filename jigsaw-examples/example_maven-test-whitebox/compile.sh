#!/usr/bin/env bash
source ../env.sh

./mvnw --version --fail-at-end 2>&1

# debug mode with -X flag
# ./mvnw -s mvn_settings.xml -X install --fail-at-end 2>&1
./mvnw -s mvn_settings.xml install --fail-at-end 2>&1