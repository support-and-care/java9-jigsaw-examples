#!/usr/bin/env bash
source ../env.sh

set -eu -o pipefail

# Additional normalization for this example to strip timestamps and ANSI codes
normalize_extra() {
  sed -E \
    's/[A-Z][a-z]{2} [0-9]{1,2}, [0-9]{4} [0-9]{1,2}:[0-9]{2}:[0-9]{2} (AM|PM)/<TIMESTAMP>/g' | \
  sed 's/\x1b\[[0-9;]*[mK]//g'
}

result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Logger using jdk14 implementation (in fact, it was a version 1.4, which is a mapping to java.util.logging)
echo
echo "Using slf4j.jdk14 as implementation for slf4j, see also #VersionsInModuleNames!"

echo "$JAVA_HOME/bin/java $JAVA_OPTIONS --module-path mlib${PATH_SEPARATOR}amlib-api${PATH_SEPARATOR}amlib-jdk14 --add-modules slf4j.jdk14 --module modmain/pkgmain.Main | myecho"
$JAVA_HOME/bin/java $JAVA_OPTIONS \
            --module-path mlib${PATH_SEPARATOR}amlib-api${PATH_SEPARATOR}amlib-jdk14 \
            --add-modules slf4j.jdk14 \
            --module modmain/pkgmain.Main 2>&1 | normalize | normalize_extra | tee -a "${result_dir}/run.txt" | myecho

# Logger using simple implementation
echo
echo "Using slf4j.simple as implementation for slf4j"

echo "$JAVA_HOME/bin/java $JAVA_OPTIONS --module-path mlib${PATH_SEPARATOR}amlib-api${PATH_SEPARATOR}amlib-simple --add-modules slf4j.simple --module modmain/pkgmain.Main | myecho"
$JAVA_HOME/bin/java $JAVA_OPTIONS \
  --module-path mlib${PATH_SEPARATOR}amlib-api${PATH_SEPARATOR}amlib-simple \
  --add-modules slf4j.simple \
  --module modmain/pkgmain.Main 2>&1 | normalize | normalize_extra | tee -a "${result_dir}/run.txt" | myecho

# Logger using both implementations for simple and jdk14 logging -> run time error ("split package") as both modules do export org.slf4j.impl
echo
echo "Exception expected: java.lang.module.ResolutionException: Modules slf4j.jdk14 and slf4j.simple export package org.slf4j.impl to module slf4j.api"
echo "$JAVA_HOME/bin/java $JAVA_OPTIONS --module-path mlib${PATH_SEPARATOR}amlib-api${PATH_SEPARATOR}amlib-simple${PATH_SEPARATOR}amlib-jdk14 --add-modules slf4j.simple\,slf4j.jdk14  --module modmain/pkgmain.Main  | myecho"
if $JAVA_HOME/bin/java $JAVA_OPTIONS \
  --module-path mlib${PATH_SEPARATOR}amlib-api${PATH_SEPARATOR}amlib-simple${PATH_SEPARATOR}amlib-jdk14 \
  --add-modules slf4j.simple\,slf4j.jdk14 \
  --module modmain/pkgmain.Main 2>&1 | normalize | normalize_extra | sed -e 's,^java.lang.module.ResolutionException:.*,java.lang.module.ResolutionException: ...,g' | tee -a "${result_dir}/run.txt" | myecho; then
  echo "An exception should occur here!" >&2
  exit 1
fi
