#!/usr/bin/env bash
source ../env.sh

mkdir -p run-result

# Allow access to moda without using the "Add-Exports" entry from MANIFEST.MF
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
   --add-exports java.base/jdk.internal.misc=modmain \
   --add-exports moda/pkgainternal=modmain \
   --module-path mlib --module modmain/pkgmain.Main 2>&1 | normalize | tee run-result/run.txt | myecho

# Allow access to moda with using the "Add-Exports" entry from MANIFEST.MF
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
   --add-modules moda \
   --module-path mlib \
   -jar mlib/modmain.jar 2>&1 | normalize | tee -a run-result/run.txt | myecho


