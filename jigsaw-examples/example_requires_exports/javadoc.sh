#!/usr/bin/env bash
source ../env.sh

rm -rf doc
mkdir -p doc

# generate JavaDoc
echo "javadoc ${JAVADOC_OPTIONS} -d doc --module-path mlib --module-source-path src $(find src -name \"*.java\")"
# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/javadoc" ${JAVADOC_OPTIONS}  -d doc \
    --module-path mlib \
    --module-source-path src $(find src -name "*.java") \
     2>&1
