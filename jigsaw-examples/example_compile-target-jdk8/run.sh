#!/usr/bin/env bash
source ../env.sh

set -eu -o pipefail

# Check whether JAVA8 is a "real" Java 8
is_real_java8() {
  java_home="${1:-}"
  if test -x "${java_home}/bin/java" && "${java_home}/bin/java" -version 2>&1 | grep -q 'version "1.8' 2>/dev/null; then
    return 0
  else
    return 1
  fi
}

result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

if ! is_real_java8 "${JAVA8_HOME}"; then
  echo "The JDK in '${JAVA8_HOME}' seems not to be a 'real' Java 8 (skipping)" | tee "${result_dir}/run.txt"
  exit 0
fi

echo
echo "Running the application with JDK8, compiled with JDK >8 for release 8"
echo "$JAVA8_HOME/bin/java $JAVA_OPTIONS  -cp cplib/cpmain-jdk8.jar  pkgmain.Main"

$JAVA8_HOME/bin/java $JAVA_OPTIONS  -cp cplib/cpmain-jdk8.jar  pkgmain.Main 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho

echo
echo "Running the application with JDK9, compiled with JDK >8 for release 9+"
echo "$JAVA_HOME/bin/java $JAVA_OPTIONS  -cp cplib/cpmain-jdk9.jar  pkgmain.Main"

$JAVA_HOME/bin/java $JAVA_OPTIONS  -cp cplib/cpmain-jdk9.jar  pkgmain.Main 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho

echo
echo "Running the application with JDK8, compiled with JDK >8 for release 9+..."
echo "This will *not* work but produce a runtime error message similar to this:"
echo "  java.lang.UnsupportedClassVersionError: pkgmain/Main has been compiled by a more recent version of the Java Runtime (class file version 53.0), this version of the Java Runtime only recognizes class file versions up to 52.0"

echo "$JAVA8_HOME/bin/java $JAVA_OPTIONS  -cp cplib/cpmain-jdk9.jar  pkgmain.Main"

if $JAVA8_HOME/bin/java $JAVA_OPTIONS  -cp cplib/cpmain-jdk9.jar  pkgmain.Main 2>&1 \
  | normalize | awk -F: '/^.+UnsupportedClassVersionError/ {print $1}' \
  | tee -a "${result_dir}/run.txt" | myecho; then
  echo "An exception should occur here!" >&2
  exit 1
fi


