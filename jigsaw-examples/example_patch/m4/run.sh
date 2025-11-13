#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

result_dir="${1:-run-result}"

rm -rf "${result_dir}"
mkdir -p "${result_dir}"

# Ensure mlib → target symlink exists and is valid
# (Needed for --module-path mlib after Maven compilation)
if [ -L mlib ] && [ ! -e mlib ]; then
  # Broken symlink, remove it
  rm mlib
fi
if [ ! -e mlib ]; then
  # Create symlink (target/ should exist from compile.sh)
  ln -s target mlib
fi

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

echo "=== Running without patch ===="
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main 2>&1 | normalize | tee ${result_dir}/run.txt | myecho

# Patch the module during startup, using a) exploded classes, b) a jar containing the patch.
#
# --patch-module modb=... does the patch (same option no matter if exploded classes or jar)

echo "=== Running with patch classes from patches/modb ===="
echo ">> Start modmain/pkgmain.Main with patch classes from patches/modb"
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --patch-module modb=patches/modb --module-path mlib --module modmain/pkgmain.Main 2>&1 | normalize | tee -a ${result_dir}/run.txt | myecho

echo "=== Running with patch JAR from patchlib/modb.jar ===="
echo ">> Start modmain/pkgmain.Main with patch classes from patchlib/modb.jar"
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --patch-module modb=patchlib/modb.jar --module-path mlib --module modmain/pkgmain.Main 2>&1 | normalize | tee -a ${result_dir}/run.txt | myecho
