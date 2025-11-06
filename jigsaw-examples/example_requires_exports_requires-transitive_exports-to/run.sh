#!/usr/bin/env bash

set -eu -o pipefail

source ../env.sh


result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"


./run-main.sh 2>&1 | normalize | tee -a "${result_dir}/run.txt"

echo " " | tee -a "${result_dir}/run.txt"
./run-mainbehindfacade.sh 2>&1 | normalize | tee -a "${result_dir}/run.txt"
