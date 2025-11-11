#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib${PATH_SEPARATOR}amlib \
    --add-modules hamcrest.core,modtest.blackbox \
    --module junit/org.junit.runner.JUnitCore \
    pkgblacktest.BlackBoxTest \
    2>&1
