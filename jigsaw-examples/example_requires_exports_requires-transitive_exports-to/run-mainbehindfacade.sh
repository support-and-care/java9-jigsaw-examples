#!/usr/bin/env bash
source ../env.sh

# shellcheck disable=SC2086  # Option variables should not be quoted
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmainbehindfacade/pkgmainbehindfacade.MainBehindFacade 2>&1 | myecho 
