#!/usr/bin/env bash
set -eu -o pipefail

mkdir -p mods
mkdir -p patches
mkdir -p mlib
mkdir -p patchlib

./compile-whiteboxtest.sh

./compile-blackboxtest.sh

echo "=== Compilation complete ==="
