#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Use JDK 11 for runtime (required for javax.json automatic module)
if [ -z "${JAVA11_HOME:-}" ]; then
  echo "ERROR: JAVA11_HOME is not set. This example requires JDK 11 to run."
  exit 1
fi

# Create run-result directory if it doesn't exist
mkdir -p run-result

echo "Using Java version:"
"${JAVA11_HOME}/bin/java" -version
echo

# Run the Java code, save output to run-result/run.txt, and display with highlighting
# The '.' argument specifies the JSON file (layers_triple_hierarchy.json) location
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA11_HOME}/bin/java" ${JAVA_OPTIONS} --module-path "target${PATH_SEPARATOR}amlib" --module mod.main/pkgmain.Main . 2>&1 | normalize | tee run-result/run.txt | myecho
