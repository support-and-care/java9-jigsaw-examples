#!/usr/bin/env bash
source ../env.sh

./apps_copyallexamples2appdir.sh

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create run-result directory if it doesn't exist
mkdir -p run-result

# Aufruf des App-Servers
echo ""
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path "mlib${PATH_SEPARATOR}amlib" --module modstarter/pkgstarter.Starter . run-result --sync 2>&1 | normalize | tee run-result/run.txt | myecho
