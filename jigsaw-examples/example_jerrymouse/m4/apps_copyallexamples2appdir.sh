#!/usr/bin/env bash

set -eu -o pipefail

#
# Copy all apps from our app whitelist (Maven 4 versions)
# This is the Maven 4 variant that copies from ../example_*/m4/mlib/ directories
#

# source the list of apps which we want to run in the Jerry Mouse app server
app_whitelist="$(cat ../apps_whitelist.txt)"

APPSERVER_TARGET=$(pwd)/apps

for dir in ${app_whitelist};
do
    MODDIR="${dir%*/}"

    # if the example really is "worth" to be copied, i.e. not empty...
    if [ ! -e "../../${MODDIR}/m4/mlib/modmain.jar" ]; then
      echo "Building Maven 4 version of ${MODDIR}..."
      (cd "../../${MODDIR}/m4" && ./compile.sh)
    fi

    pushd "../../${MODDIR}/m4" > /dev/null 2>&1
    echo "###################################################################################################################################"
    echo "Copy ${MODDIR}/m4/mlib/*.jar to ${APPSERVER_TARGET}/${MODDIR} ..."

    mkdir -p "${APPSERVER_TARGET}"/"${MODDIR}"
    pushd "${APPSERVER_TARGET}"/"${MODDIR}" > /dev/null 2>&1
    rm -rf ./*

    cat > app.json <<EOFAPPJSON
{
  "rootModule": "modmain",
  "bootClass":  "pkgmain.Main",
  "bootMethod": "main"
}
EOFAPPJSON
    mkdir -p "${APPSERVER_TARGET}"/"${MODDIR}/mlib"
    popd >/dev/null 2>&1

    pushd mlib > /dev/null 2>&1
    cp -R ./*.jar "${APPSERVER_TARGET}"/"${MODDIR}/mlib"
    popd >/dev/null 2>&1

    echo
    popd >/dev/null 2>&1
done