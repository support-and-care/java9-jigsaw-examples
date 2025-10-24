#!/usr/bin/env bash
source ../env.sh

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create run-result directory if it doesn't exist
mkdir -p run-result

"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} \
      --module-path mlib \
      --class-path cplib/cpb.jar \
      --module modmain/pkgmain.Main \
      2>&1 | normalize | tee run-result/run.txt | myecho
