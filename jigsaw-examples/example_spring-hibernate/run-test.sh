#!/usr/bin/env bash
source ../env.sh

pushd src > /dev/null 2>&1

./mvnw --version

./mvnw -B -s ../mvn_settings.xml -e test 2>&1

popd >/dev/null 2>&1 
