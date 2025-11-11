#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
    --patch-module modfib=patchlib/modfib.jar \
    --module-path mlib${PATH_SEPARATOR}amlib \
    --add-reads modfib=junit \
    --add-modules ALL-MODULE-PATH \
    --module junit/org.junit.runner.JUnitCore \
    pkgfib.WhiteBoxTest \
    2>&1
