#!/usr/bin/env bash
source ../env.sh

./mvnw --version --fail-at-end 2>&1
./mvnw -B -s mvn_settings.xml clean --fail-at-end 2>&1
