#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Use JDK 11 for runtime (required to access JDK 11 internals)
if [ -z "${JAVA11_HOME:-}" ]; then
  echo "ERROR: JAVA11_HOME is not set. This example requires JDK 11 to run."
  exit 1
fi

# Show Java version for user information
echo "Using Java version:"
"${JAVA11_HOME}/bin/java" -version
echo

# Create run-result directory if it doesn't exist
mkdir -p run-result

# First run: Allow access to moda without using the "Add-Exports" entry from MANIFEST.MF
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA11_HOME}/bin/java" ${JAVA_OPTIONS} \
   --add-exports java.base/jdk.internal.misc=modmain \
   --add-exports moda/pkgainternal=modmain \
   --module-path target --module modmain/pkgmain.Main 2>&1 | normalize | tee run-result/run.txt | myecho

# Second run: Allow access to moda with using the "Add-Exports" entry from MANIFEST.MF
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA11_HOME}/bin/java" ${JAVA_OPTIONS} \
   --add-modules moda \
   --module-path target \
   -jar target/example_addExports_manifest-m4-1.0-SNAPSHOT-modmain.jar 2>&1 | normalize | tee -a run-result/run.txt | myecho
