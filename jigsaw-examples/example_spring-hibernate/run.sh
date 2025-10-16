#!/usr/bin/env bash
source ../env.sh

pushd src/mod.app > /dev/null 2>&1

../mvnw --version

../mvnw -s ../../mvn_settings.xml -e spring-boot:run 2>&1

popd >/dev/null 2>&1 


