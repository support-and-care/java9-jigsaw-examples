#!/usr/bin/env bash

set -eu -o pipefail

source ../env.sh

mkdir -p run-result

./run-blackboxtest.sh 2>&1 | normalize | sed 's/\x1b\[[0-9;]*[mKGH]//g' | grep -v "^Time: " | tee run-result/run.txt

echo " " | tee -a run-result/run.txt
./run-whiteboxtest.sh 2>&1 | normalize | sed 's/\x1b\[[0-9;]*[mKGH]//g' | grep -v "^Time: " | tee -a run-result/run.txt

echo " " | tee -a run-result/run.txt
./run-whiteboxtest_with-optionsfile.sh 2>&1 | normalize | sed 's/\x1b\[[0-9;]*[mKGH]//g' | grep -v "^Time: " | tee -a run-result/run.txt
