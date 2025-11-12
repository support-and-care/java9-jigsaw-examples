# Environment settings
# shellcheck shell=bash

set -eu -o pipefail

# configure paths here

# Path to JDK9 or JDK10 (9.0.1, 9.0.4 and 10_18.3_10+46 have been tested)
# Recommended: JDK 11.0.28 (Temurin) - same as CI/CD pipeline
# SDKMAN Users: .sdkmanrc at repository root configures JDK 11.0.28 automatically
[ -z "${JAVA_HOME:-}" ] && export JAVA_HOME=TODO/path/to/java9-or-10-jdk/goes/here

# Path to JDK8, only needed in example_compile-target-jdk8 (and special profile in example_spring-hibernate)
[ -z "${JAVA8_HOME:-}" ] && export JAVA8_HOME=TODO/path/to/java8-jdk/goes/here

# Path to JDK11, only needed for specific examples (e.g., example_version/m4 runtime)
[ -z "${JAVA11_HOME:-}" ] && export JAVA11_HOME=TODO/path/to/java11-jdk/goes/here

# Path to JDK17, only needed in example_gradle-project and Maven 4 builds
[ -z "${JAVA17_HOME:-}" ] && export JAVA17_HOME=TODO/path/to/java17-jdk/goes/here

# Path to Eclipse (legacy compatibility, not recommended for new work)
[ -z "${ECLIPSE_HOME:-}" ] && export ECLIPSE_HOME=TODO/path/to/eclipse/goes/here

# Note: MAVEN_HOME and GRADLE_HOME are no longer needed as all Maven and Gradle
# examples now include wrappers (Maven Wrapper 3.9.11, Gradle Wrapper 9.1.0)
# Use ./mvnw or ./gradlew instead

# Path to Maven 4 (required for m4/ migration subdirectories)
# SDKMAN Users: Use 'sdk install maven 4.0.0-beta-5' or similar
# Note: M4_HOME/bin is added to PATH in m4/ scripts, not here
[ -z "${M4_HOME:-}" ] && export M4_HOME=TODO/path/to/maven4/goes/here

# Path to Maven 3 (optional, for future m3/ migration comparisons)
# SDKMAN Users: Use 'sdk install maven 3.9.11' or similar
[ -z "${M3_HOME:-}" ] && export M3_HOME=TODO/path/to/maven3/goes/here

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

normalize_jlink() {
  local java_home
  java_home="${1}"
  # shellcheck disable=SC2086  # intentional word splitting
  sed \
    -e "s,${normalized_jlink_pwd},<PROJECT_ROOT>,g" \
    -e "s,$(normalize_for_jlink ${java_home}),<JAVA_HOME>,g"
}
