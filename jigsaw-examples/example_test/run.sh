#!/usr/bin/env bash

set -eu -o pipefail

source ../env.sh


result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"


./run-blackboxtest.sh 2>&1 | normalize | sed 's/\x1b\[[0-9;]*[mKGH]//g' | grep -v "^Time: " | tee -a "${result_dir}/run.txt"

echo " " | tee -a "${result_dir}/run.txt"
./run-whiteboxtest.sh 2>&1 | normalize | sed 's/\x1b\[[0-9;]*[mKGH]//g' | grep -v "^Time: " | tee -a "${result_dir}/run.txt"

echo " " | tee -a "${result_dir}/run.txt"
./run-whiteboxtest_with-optionsfile.sh 2>&1 | normalize | sed 's/\x1b\[[0-9;]*[mKGH]//g' | grep -v "^Time: " | tee -a "${result_dir}/run.txt"
