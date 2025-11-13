#!/usr/bin/env bash
set -eu -o pipefail

echo "Cleaning Maven 4 build artifacts..."

rm -rf target
rm -rf patches
rm -rf patchlib
rm -rf run-result

echo "✅ Clean complete"
