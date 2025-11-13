#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create run-result directory (clean first)
rm -rf run-result
mkdir -p run-result
touch run-result/run.txt

# Run the Java code, save output to run-result/run.txt, and display with highlighting
# Additional normalization for this example to strip timestamps and ANSI codes
normalize_extra() {
  sed -E \
    's/[A-Z][a-z]{2} [0-9]{1,2}, [0-9]{4} [0-9]{1,2}:[0-9]{2}:[0-9]{2} (AM|PM)/<TIMESTAMP>/g' | \
  sed 's/\x1b\[[0-9;]*[mK]//g'
}

# Logger using jdk14 implementation
echo
echo "Using slf4j.jdk14 as implementation for slf4j, see also #VersionsInModuleNames!"

# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
            --module-path target"${PATH_SEPARATOR}"amlib-api"${PATH_SEPARATOR}"../amlib-jdk14 \
            --add-modules slf4j.jdk14 \
            --module modmain/pkgmain.Main 2>&1 | normalize | normalize_extra | tee -a run-result/run.txt | myecho

# Logger using simple implementation
echo
echo "Using slf4j.simple as implementation for slf4j"

# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
  --module-path target"${PATH_SEPARATOR}"amlib-api"${PATH_SEPARATOR}"../amlib-simple \
  --add-modules slf4j.simple \
  --module modmain/pkgmain.Main 2>&1 | normalize | normalize_extra | tee -a run-result/run.txt | myecho

# Logger using both implementations -> expected error
echo
echo "Exception expected: java.lang.module.ResolutionException: Modules slf4j.jdk14 and slf4j.simple export package org.slf4j.impl to module slf4j.api"
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
if "${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
  --module-path target"${PATH_SEPARATOR}"amlib-api"${PATH_SEPARATOR}"../amlib-simple"${PATH_SEPARATOR}"../amlib-jdk14 \
  --add-modules slf4j.simple\,slf4j.jdk14 \
  --module modmain/pkgmain.Main 2>&1 | normalize | normalize_extra | sed -e 's,^java.lang.module.ResolutionException:.*,java.lang.module.ResolutionException: ...,g' | tee -a run-result/run.txt | myecho; then
  echo "An exception should occur here!" >&2
  exit 1
fi
