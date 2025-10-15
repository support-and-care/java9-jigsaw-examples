# Environment settings

# configure paths here

# Path to JDK9 or JDK10 (9.0.1, 9.0.4 and 10_18.3_10+46 have been tested)
[ -z "$JAVA_HOME" ] && export JAVA_HOME=TODO/path/to/java9-or-10-jdk/goes/here

# Path to JDK8, only needed in example_compile-target-jdk8
[ -z "$JAVA8_HOME" ] && export JAVA8_HOME=TODO/path/to/java8-jdk/goes/here

# Path to Eclipse 4.7.3a Oxygen.3a (but 4.7.1a Oxygen.1a should still work)
[ -z "$ECLIPSE_HOME" ] && export ECLIPSE_HOME=TODO/path/to/eclipse4.7.3a/goes/here

# Path to Maven >=3.5.2
export MAVEN_HOME=TODO/path/to/Maven3.5.2/goes/here
export M2_HOME=${MAVEN_HOME}

# Path to GraphViz >=2.38
[ -z "$GRAPHVIZ_HOME" ] && export GRAPHVIZ_HOME=TODO/path/to/graphviz2.38/goes/here
# Path to DepVis , see https://github.com/accso/java9-jigsaw-depvis
[ -z "$DEPVIS_HOME" ] && export DEPVIS_HOME=TODO/path/to/depvis/goes/here

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
JAVAC_OPTIONS="-Xlint"
# JAVA_OPTIONS="-XshowSettings:all -Xlog:module=trace -showversion --show-module-resolution"
JAVA_OPTIONS="-showversion"
JAR_OPTIONS=""
JAVADOC_OPTIONS=""

# ---------------------------------------------------------
# no need to change anything beyond this line

export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

# helper echo to highlight errors on the terminal
function myecho {
    egrep --color=always "Error|error|Exception|exception|Warn|warn|$" $@
}
