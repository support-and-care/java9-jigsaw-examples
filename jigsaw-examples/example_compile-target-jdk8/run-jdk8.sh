#!/usr/bin/env bash
source ../env.sh

if test "${USE_JAVA8}" != "true"; then
  echo "There seems to be no 'real' Java 8 available on this system (check '${JAVA8_HOME}' (skipping)"
  exit 0
fi

echo "Running the application with JDK8, compiled with JDK9 for release 8"
echo "$JAVA8_HOME/bin/java $JAVA_OPTIONS  -cp cplib/cpmain-jdk8.jar  pkgmain.Main"

$JAVA8_HOME/bin/java $JAVA_OPTIONS  -cp cplib/cpmain-jdk8.jar  pkgmain.Main 2>&1 | myecho
