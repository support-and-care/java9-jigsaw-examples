#!/usr/bin/env bash
cat readme.md

./run-blackboxtest.sh

echo " "
./run-whiteboxtest.sh

echo " "
./run-whiteboxtest_with-optionsfile.sh
