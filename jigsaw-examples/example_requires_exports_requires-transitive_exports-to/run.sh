#!/usr/bin/env bash

set -eu -o pipefail

source ../env.sh

mkdir -p run-result

./run-main.sh 2>&1 | normalize | tee run-result/run.txt

echo " " | tee -a run-result/run.txt
./run-mainbehindfacade.sh 2>&1 | normalize | tee -a run-result/run.txt
