#!/usr/bin/env bash
source ../env.sh

set -eu -o pipefail

result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

for dir in mlib amlib1 amlib2 amlib3 amlib4
do
    pushd "${dir}" > /dev/null 2>&1 || exit
    # shellcheck disable=SC2012 disable=SC2035 # We want to use ls here for sorting
    for JAR in $(ls *.jar | LC_ALL=C LANG=C LC_CTYPE=C sort)
    do
        echo "JAR-file: ${JAR} in ${dir}"
        
        # get name of JAR-file
        MOD="$(basename "${JAR}" | sed s/'.jar'//g | sed s/'-'/'.'/g | cut -d '.' -f 1-2)"
    
        echo "java --module-path . --module ${MOD}/pkgmain.Main"
        if ! "${JAVA_HOME}/bin/java" --module-path . --module "${MOD}/pkgmain.Main"  2>&1 | normalize | tee -a "../${result_dir}/run.txt" | myecho; then
            echo "Cannot execute Module ${MOD}" | normalize | tee -a "../${result_dir}/run.txt"
        fi
    
        echo " "
    done
popd > /dev/null 2>&1 || exit
done