#!/usr/bin/env bash

set -eu -o pipefail

./run-blackboxtest.sh

echo " "
./run-whiteboxtest.sh

echo " "
./run-whiteboxtest_with-optionsfile.sh
