#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create run-result directory if it doesn't exist
mkdir -p run-result

# Demonstration of split package problem at runtime
# Match the original output format for golden master testing
{
  # Foo modules: Not compiled in M4 version (they have compile-time split package issues)
  echo "Error: Does not run, as it does not even compile!"

  echo

  # Bar modules: Demonstrate runtime split package problem
  # shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
  "${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path target --module modmainbar/pkgmainbar.Main 2>&1

  # This should fail with LayerInstantiationException because both modules have package pkgbar
  # shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
  if "${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path target --add-modules modsplitbar2 --module modmainbar/pkgmainbar.Main 2>&1; then
    echo "A runtime exception was expected here" >&2
    exit 1
  fi
} | normalize | sed -e 's/\x1b\[[0-9;]*[mKGH]//g' -e 's/Package pkgbar in both.*/Package pkgbar in two different modules/g' | tee run-result/run.txt | myecho
