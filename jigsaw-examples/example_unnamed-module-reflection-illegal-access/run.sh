#!/usr/bin/env bash
source ../env.sh

set -eu -o pipefail

result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

"${JAVA_HOME}/bin/java" --version

#
# Run main class, which does reflective access to a class from module java.base, package jdk.internal (a package which is new in Java9)
# Only variant #5 will work (with explicit --add-opens), while variant #1 will throw:
#     java.lang.reflect.InaccessibleObjectException: Unable to make private jdk.internal.math.DoubleConsts() accessible: module java.base does not "opens jdk.internal.math" to unnamed module
# Note: Variants 2-4 with --illegal-access flag were removed - the flag was removed in Java 17 (JEP 403).

echo "Checking variants of reflective access to java.base/jdk.internal.math.DoubleConsts. Its package is new in Java9!"

echo
echo "1 - reflective call without any options"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java"                         --module-path mlib -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseJDKInternal 2>&1 | normalize | tee "${result_dir}"/run.txt | myecho; then
  echo "ERROR: Variant 1 - Expected exception but command succeeded"
  exit 1
fi
# Variants 2, 3, 4 removed: --illegal-access flag was removed in Java 17
# See https://openjdk.org/jeps/403 - The behavior is now always "deny"
echo
echo "5 - reflective call with explicit --add-opens"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --add-opens=java.base/jdk.internal.math=ALL-UNNAMED --module-path mlib -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseJDKInternal 2>&1 | normalize | tee -a "${result_dir}"/run.txt | myecho; then
  echo "ERROR: Variant 5 - Expected success but got exception"
  exit 1
fi

echo

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#
# Run main class, which does reflective access to a class from module java.base, package sun.net (a package which has existed before, in Java 8)
# Since Java 17, only variant #10 works (with explicit --add-opens).
# Note: Variants 6-9 with --illegal-access flag were removed - the flag was removed in Java 17 (JEP 403).

echo "Checking variants of reflective access to java.base/sun.net.PortConfig. Its package is not new in Java 9, but had existed before in Java8!"

echo
echo "10 - reflective call with explicit --add-opens"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --add-opens=java.base/sun.net=ALL-UNNAMED --module-path mlib -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseSunNet 2>&1 | normalize | tee -a "${result_dir}"/run.txt | myecho; then
  echo "ERROR: Variant 10 - Expected success but got exception"
  exit 1
fi

echo

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#
# Run main class, which does reflective access to a class from module java.desktop, package sun.awt
# (a package which has existed before, in Java8). Since Java 17, only variant #15 works (with explicit --add-opens).
# Prior to Java 17, variants 11-13 worked when --illegal-access=permit was the default.
#

echo "Checking variants of reflective access to java.desktop/sun.awt.OSInfo. Its package is not new in Java9, but had existed before in Java8!"

# Variants 11-14 removed: --illegal-access flag was removed in Java 17
# Previously, variants 11-13 relied on --illegal-access=permit being the default
# (allowing reflective access to packages that existed before Java 9).
# Since Java 17, the behavior is always "deny" - explicit --add-opens is required.
# See https://openjdk.org/jeps/403
echo
echo "15 - reflective call with explicit --add-opens"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --add-opens=java.desktop/sun.awt=ALL-UNNAMED --module-path mlib -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaDesktop 2>&1 | normalize | tee -a "${result_dir}"/run.txt | myecho; then
  echo "ERROR: Variant 15 - Expected success but got exception"
  exit 1
fi

echo

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#
# Run main class, which does reflective access to a class from module modb (whose packages had not existed before Java9)
# Only variant #20 will work (with explicit --add-opens), while variant #16 will throw InaccessibleObjectException.
# Note: Variants 17-19 with --illegal-access flag were removed - the flag was removed in Java 17 (JEP 403).
# The --illegal-access flag never applied to application modules like modb anyway; it only affected JDK internal packages.
#

echo "Checking variants of reflective access to the following classes in own module modb:"
echo "    class pkgb.BFromModule                                      is public and exported"
echo "    class pkgbinternal.BFromModuleButInternal                   is not exported"
echo "    class pkgbexportedqualified.BFromModuleButExportedQualified is exported, but only qualified to modc (and hence not to the unnamed module)"

echo
echo "16 - reflective call without any options"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java"                         --module-path mlib -cp cplib/cpmain.jar --add-modules modb pkgcpmain.MainCallingModB 2>&1 | normalize | tee -a "${result_dir}"/run.txt | myecho; then
  echo "ERROR: Variant 16 - Expected exception but command succeeded"
  exit 1
fi
# Variants 17, 18, 19 removed: --illegal-access flag was removed in Java 17
# The --illegal-access flag never applied to application modules like modb anyway;
# it only affected access to JDK internal packages. See https://openjdk.org/jeps/403
echo
echo "20 - reflective call with explicit --add-opens"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --add-opens=modb/pkgbinternal=ALL-UNNAMED --add-opens modb/pkgbexportedqualified=ALL-UNNAMED --module-path mlib -cp cplib/cpmain.jar --add-modules modb pkgcpmain.MainCallingModB 2>&1 | normalize | tee -a "${result_dir}"/run.txt | myecho; then
  echo "ERROR: Variant 20 - Expected success but got exception"
  exit 1
fi
