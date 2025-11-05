#!/usr/bin/env bash
source ../env.sh

# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib${PATH_SEPARATOR}amlib \
     --add-modules hamcrest.core,modtest.blackbox \
     --module junit/org.junit.runner.JUnitCore \
     pkgblacktest.BlackBoxTest \
      2>&1
