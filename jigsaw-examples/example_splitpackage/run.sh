#!/usr/bin/env bash

source ../env.sh

mkdir -p run-result

./run-foo.sh 2>&1 | normalize | sed -e 's/\x1b\[[0-9;]*[mKGH]//g' -e 's/Package pkgbar in both.*/Package pkgbar in two different modules/g' | tee run-result/run.txt

echo | tee -a run-result/run.txt
./run-bar.sh 2>&1 | normalize | sed -e 's/\x1b\[[0-9;]*[mKGH]//g' -e 's/Package pkgbar in both.*/Package pkgbar in two different modules/g' | tee -a run-result/run.txt
