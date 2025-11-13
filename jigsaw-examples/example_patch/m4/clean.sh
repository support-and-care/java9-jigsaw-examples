#!/usr/bin/env bash
set -eu -o pipefail

echo "Cleaning Maven 4 build artifacts..."

rm -rf target
rm -rf patches
rm -rf patchlib
# Only remove mlib on Windows (where it's a directory with copied JARs)
# On Unix, mlib is a committed symlink and should remain
[ "${OS:-$(uname)}" = "Windows_NT" ] && rm -rf mlib
rm -rf run-result

echo "✅ Clean complete"
