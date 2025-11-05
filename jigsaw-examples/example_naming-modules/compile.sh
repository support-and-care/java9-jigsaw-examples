#!/usr/bin/env bash
source ../env.sh

mkdir -p mods
mkdir -p mlib
mkdir -p classes

# compile all directories which have a module-info.java (any but automatic*)

pushd src > /dev/null 2>&1 || exit
for dir in */
do
    dir="${dir%/}"
    # Skip directories starting with "automatic"
    if [[ ! "$dir" =~ ^automatic ]]; then
        echo "javac ${JAVAC_OPTIONS}  -d ../mods --module-path ../mlib --module-source-path . \$(find ${dir} -name \"*.java\")"
        # shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
        "${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS}  -d ../mods --module-path ../mlib --module-source-path . $(find "${dir}" -name '*.java') 2>&1
    fi
done
popd >/dev/null 2>&1 || exit

pushd mods > /dev/null 2>&1 || exit
for dir in */
do
    MODDIR="${dir%/}"
    # Skip directories starting with "automatic"
    if [[ ! "$MODDIR" =~ ^automatic ]]; then
        echo "jar ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar -C ${MODDIR} ."
        # shellcheck disable=SC2086  # Option variables should not be quoted
        "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../mlib/${MODDIR}.jar ${JAR_OPTIONS} --module-version 0.1 -C ${MODDIR} . 2>&1
    fi
done
popd >/dev/null 2>&1 || exit

# ---------------------------------------------------

# compile automatic* to non-modular JAR-file (into separate amlib* directories)

counter=0
for dir in automatic-whatever automatic-whateverX-47.11 automatic-whateverX48.12 automatic-whateverX49-13
do
    pushd src > /dev/null 2>&1 || exit
    echo "javac ${JAVAC_OPTIONS}  -d ../classes/${dir} \$(find ${dir} -name \"*.java\")"
    # shellcheck disable=SC2046,SC2086  # Word splitting is intentional for find results; option variables should not be quoted
    "${JAVA_HOME}/bin/javac" ${JAVAC_OPTIONS}  -d ../classes/${dir} $(find ${dir} -name '*.java') 2>&1

    counter=$((counter+1))
    echo "jar ${JAR_OPTIONS} --create --file=../amlib${counter}/${dir}.jar -C ../classes/${dir} ."
    # shellcheck disable=SC2086  # Option variables should not be quoted
    "${JAVA_HOME}/bin/jar" ${JAR_OPTIONS} --create --file=../amlib${counter}/${dir}.jar -C ../classes/${dir} . 2>&1
    
    popd >/dev/null 2>&1  || exit
done
