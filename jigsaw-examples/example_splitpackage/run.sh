#!/usr/bin/env bash

source ../env.sh


result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"


./run-foo.sh 2>&1 | normalize | sed -e 's/\x1b\[[0-9;]*[mKGH]//g' -e 's/Package pkgbar in both.*/Package pkgbar in two different modules/g' | tee -a "${result_dir}/run.txt"

echo | tee -a "${result_dir}/run.txt"
./run-bar.sh 2>&1 | normalize | sed -e 's/\x1b\[[0-9;]*[mKGH]//g' -e 's/Package pkgbar in both.*/Package pkgbar in two different modules/g' | tee -a "${result_dir}/run.txt"
