# Environment settings
# shellcheck shell=bash

set -eu -o pipefail

# configure paths here

# Path to JDK9 or JDK10 (9.0.1, 9.0.4 and 10_18.3_10+46 have been tested)
[ -z "${JAVA_HOME:-}" ] && export JAVA_HOME=TODO/path/to/java9-or-10-jdk/goes/here

# Path to JDK8, only needed in example_compile-target-jdk8 (and special profile in example_spring-hibernate)
[ -z "${JAVA8_HOME:-}" ] && export JAVA8_HOME=TODO/path/to/java8-jdk/goes/here

# Path to JDK17, only needed in example_gradle-project
[ -z "${JAVA17_HOME:-}" ] && export JAVA17_HOME=TODO/path/to/java8-jdk/goes/here

# Check whether JAVA8 is a "real" Java 8
if test -x "${JAVA8_HOME}/bin/java" && "${JAVA8_HOME}/bin/java" -version 2>&1 | grep -q 'version "1.8' 2>/dev/null; then
  USE_JAVA8=true
else
  USE_JAVA8=false
fi
export USE_JAVA8

# Path to Eclipse 4.7.3a Oxygen.3a (but 4.7.1a Oxygen.1a should still work)
[ -z "${ECLIPSE_HOME:-}" ] && export ECLIPSE_HOME=TODO/path/to/eclipse4.7.3a/goes/here

# Note: MAVEN_HOME and GRADLE_HOME are no longer needed as all Maven and Gradle
# examples now include wrappers (Maven Wrapper 3.9.11, Gradle Wrapper 9.1.0)
# Use ./mvnw or ./gradlew instead

# Path to GraphViz >=2.38
[ -z "${GRAPHVIZ_HOME:-}" ] && export GRAPHVIZ_HOME=TODO/path/to/graphviz2.38/goes/here
# Path to DepVis , see https://github.com/accso/java9-jigsaw-depvis
[ -z "${DEPVIS_HOME:-}" ] && export DEPVIS_HOME=TODO/path/to/depvis/goes/here

# Set PATH_SEPARATOR: ';' on Windows (even when in bash), ':' on Un*x
case "$(uname | tr '[:lower:]' '[:upper:]')" in
  CYGWIN* | MINGW* | MSYS*) PATH_SEPARATOR=";" ;;
  *) PATH_SEPARATOR=":" ;;
esac
export PATH_SEPARATOR

# ---------------------------------------------------------

# Probably only needed on Windows, in Babun
# export HOME=$HOME

# ---------------------------------------------------------

#
# options used for javac (compile), jar (packaging) and java (launch)
#
# NOTE: Be careful with JAVA_OPTIONS that produce output (like -showversion, -XshowSettings, etc.)
# as they will affect golden master test result comparison in examples using verify.sh
export JAVAC_OPTIONS="-Xlint"
# JAVA_OPTIONS="-XshowSettings:all -Xlog:module=trace -showversion --show-module-resolution"
export JAVA_OPTIONS=""
export JAR_OPTIONS=""
export JAVADOC_OPTIONS=""

# ---------------------------------------------------------
# no need to change anything beyond this line

export PATH="$JAVA_HOME/bin:$PATH"

# helper echo to highlight errors on the terminal
myecho() {
    grep -E --color=always "Error|error|Exception|exception|Warn|warn|$"
}

# normalize output for cross-platform compatibility
# - strips carriage returns (Windows line endings)
# - converts backslashes to forward slashes (Windows paths)
# - removes Windows-specific modules from module lists
normalize() {
  # shellcheck disable=SC1003
  tr -d '\r' |
    tr '\\' '/' |
    sed -e '/[[:space:]]*module jdk\.accessibility[[:space:]]*/d' \
      -e '/[[:space:]]*module jdk\.crypto\.mscapi[[:space:]]*/d' \
      -e 's/jdk\.accessibility, //g' \
      -e 's/, jdk\.accessibility//g' \
      -e 's/jdk\.crypto\.mscapi, //g' \
      -e 's/, jdk\.crypto\.mscapi//g' \
      -e 's/^WARNING:.*$/WARNING - content dropped due to output normalization/g'
}

normalize_for_jlink() {
  # Handle Windows-style paths (convert X: to /x/)
  case "$(uname | tr '[:lower:]' '[:upper:]')" in
    CYGWIN* | MINGW* | MSYS*)
      echo "${*}" | sed -r 's,^/([A-Za-z]),/\U\1\:,'
    ;;
    *)
      echo "${*}"
    ;;
  esac
}
normalized_jlink_pwd=$(normalize_for_jlink "${PWD}")
normalized_jlink_java_home=$(normalize_for_jlink "${JAVA_HOME}")

normalize_jlink() {
  sed \
    -e "s,${normalized_jlink_pwd},<PROJECT_ROOT>,g" \
    -e "s,${normalized_jlink_java_home},<JAVA_HOME>,g"
}

