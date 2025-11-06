#!/usr/bin/env bash
source ../env.sh


result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"


# Allow access to moda without using the "Add-Exports" entry from MANIFEST.MF
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
   --add-exports java.base/jdk.internal.misc=modmain \
   --add-exports moda/pkgainternal=modmain \
   --module-path mlib --module modmain/pkgmain.Main 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho

# Allow access to moda with using the "Add-Exports" entry from MANIFEST.MF
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
   --add-modules moda \
   --module-path mlib \
   -jar mlib/modmain.jar 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho


