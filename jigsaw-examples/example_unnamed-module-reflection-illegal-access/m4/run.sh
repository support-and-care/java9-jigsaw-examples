#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# IMPORTANT: This example MUST run with JDK 11 (not JDK 17)
# The --illegal-access flag was removed in JDK 17, but this example tests
# the --illegal-access=permit DEFAULT behavior of JDK 9-16.
# Variant 6-8 expect to work because --illegal-access=permit is the default in JDK 11.
if [ -z "${JAVA11_HOME:-}" ] || [ "${JAVA11_HOME}" = "TODO/path/to/java11-jdk/goes/here" ]; then
  echo "ERROR: This example requires JDK 11 to run (--illegal-access flag was removed in JDK 17)"
  echo "Please set JAVA11_HOME in .envrc or env.sh"
  exit 1
fi

# Use JDK 11 for running (not the current JAVA_HOME which might be JDK 17)
export JAVA_HOME="${JAVA11_HOME}"

result_dir="${1:-run-result}"

rm -rf "${result_dir}"

mkdir -p "${result_dir}"
touch "${result_dir}/run.txt"

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

"${JAVA_HOME}/bin/java" --version

#
# Run main class, which does reflective access to a class from module java.base, package jdk.internal (a package which is new in Java9)
# Only variant #5 will work, while variants #1,#2,#3,#4 will show this exception:
#     java.lang.reflect.InaccessibleObjectException: Unable to make private jdk.internal.math.DoubleConsts() accessible: module java.base does not "opens jdk.internal.math" to unnamed module

echo "Checking variants of reflective access to java.base/jdk.internal.math.DoubleConsts. Its package is new in Java9!"

echo
echo "1 - reflective call without any options"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java" --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseJDKInternal 2>&1 | normalize | tee "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 1 - Expected exception but command succeeded"
  exit 1
fi
echo
echo "2 - reflective call with --illegal-access=permit"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java" --illegal-access=permit --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseJDKInternal 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 2 - Expected exception but command succeeded"
  exit 1
fi
echo
echo "3 - reflective call with --illegal-access=warn"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java" --illegal-access=warn --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseJDKInternal 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 3 - Expected exception but command succeeded"
  exit 1
fi
echo
echo "4 - reflective call with --illegal-access=deny"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java" --illegal-access=deny --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseJDKInternal 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 4 - Expected exception but command succeeded"
  exit 1
fi
echo
echo "5 - reflective call with explicit --add-opens"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --add-opens=java.base/jdk.internal.math=ALL-UNNAMED --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseJDKInternal 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 5 - Expected success but got exception"
  exit 1
fi

echo

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#
# Run main class, which does reflective access to a class from module java.base, package sun.net (a package which has existed before, in Java 8)
# Variants #5,#6, #7 and #8 will work, while
#     variant #9 will show java.lang.reflect.InaccessibleObjectException: Unable to make private sun.net.PortConfig() accessible: module java.base does not "opens sun.net" to unnamed module
#     variant #10 will show java.lang.ClassNotFoundException: sun.net.PortConfig

echo "Checking variants of reflective access to java.base/sun.net.PortConfig. Its package is not new in Java 9, but had existed before in Java8!"

echo
echo "6 - reflective call without any options"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseSunNet 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 6 - Expected success but got exception"
  exit 1
fi
echo
echo "7 - reflective call with --illegal-access=permit"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --illegal-access=permit --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseSunNet 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 7 - Expected success but got exception"
  exit 1
fi
echo
echo "8 - reflective call with --illegal-access=warn"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --illegal-access=warn --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseSunNet 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 8 - Expected success but got exception"
  exit 1
fi
echo
echo "9 - reflective call with --illegal-access=deny"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java" --illegal-access=deny --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseSunNet 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 9 - Expected exception but command succeeded"
  exit 1
fi

echo
echo "10 - reflective call with explicit --add-opens"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --add-opens=java.base/sun.net=ALL-UNNAMED --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaBaseSunNet 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 10 - Expected success but got exception"
  exit 1
fi

echo

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#
# Run main class, which does reflective access to a class from module java.desktop (a package which has existed before, in Java8)
# Variants #11,#12,#13 and #15 will work, while variant #14 will show this exception:
#     java.lang.reflect.InaccessibleObjectException: Unable to make public com.sun.java.swing.plaf.nimbus.NimbusLookAndFeel() accessible: module java.desktop does not "exports com.sun.java.swing.plaf.nimbus" to unnamed modul
#

echo "Checking variants of reflective access to java.desktop/com.sun.java.swing.plaf.nimbus.NimbusLookAndFeel. Its package is not new in Java9, but had existed before in Java8!"

echo
echo "11 - reflective call without any options"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaDesktop 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 11 - Expected success but got exception"
  exit 1
fi
echo
echo "12 - reflective call with --illegal-access=permit"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --illegal-access=permit --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaDesktop 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 12 - Expected success but got exception"
  exit 1
fi
echo
echo "13 - reflective call with --illegal-access=warn"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --illegal-access=warn --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaDesktop 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 13 - Expected success but got exception"
  exit 1
fi
echo
echo "14 - reflective call with --illegal-access=deny"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java" --illegal-access=deny --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaDesktop 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 14 - Expected exception but command succeeded"
  exit 1
fi
echo
echo "15 - reflective call with explicit --add-opens"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --add-opens=java.desktop/com.sun.java.swing.plaf.nimbus=ALL-UNNAMED --module-path target -cp cplib/cpmain.jar pkgcpmain.MainCallingJavaDesktop 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 15 - Expected success but got exception"
  exit 1
fi

echo

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#
# Run main class, which does reflective access to a class from module modb (whose packages had not existed before Java9)
# Only variant #20 will work, while variants #16,#17,#18, and #19 will show this exception:
#     java.lang.reflect.InaccessibleObjectException: Unable to make public pkgbinternal.BFromModuleButInternal() accessible: module modb does not "exports pkgbinternal" to unnamed module
#

echo "Checking variants of reflective access to the following classes in own module modb:"
echo "    class pkgb.BFromModule                                      is public and exported"
echo "    class pkgbinternal.BFromModuleButInternal                   is not exported"
echo "    class pkgbexportedqualified.BFromModuleButExportedQualified is exported, but only qualified to modc (and hence not to the unnamed module)"

echo
echo "16 - reflective call without any options"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java" --module-path target -cp cplib/cpmain.jar --add-modules modb pkgcpmain.MainCallingModB 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 16 - Expected exception but command succeeded"
  exit 1
fi
echo
echo "17 - reflective call with --illegal-access=permit"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java" --illegal-access=permit --module-path target -cp cplib/cpmain.jar --add-modules modb pkgcpmain.MainCallingModB 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 17 - Expected exception but command succeeded"
  exit 1
fi
echo
echo "18 - reflective call with --illegal-access=warn"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java" --illegal-access=warn --module-path target -cp cplib/cpmain.jar --add-modules modb pkgcpmain.MainCallingModB 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 18 - Expected exception but command succeeded"
  exit 1
fi
echo
echo "19 - reflective call with --illegal-access=deny"
echo "Should throw InaccessibleObjectException"
if "${JAVA_HOME}/bin/java" --illegal-access=deny --module-path target -cp cplib/cpmain.jar --add-modules modb pkgcpmain.MainCallingModB 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 19 - Expected exception but command succeeded"
  exit 1
fi
echo
echo "20 - reflective call with explicit --add-opens"
echo "Should work without problems"
if ! "${JAVA_HOME}/bin/java" --add-opens=modb/pkgbinternal=ALL-UNNAMED --add-opens modb/pkgbexportedqualified=ALL-UNNAMED --module-path target -cp cplib/cpmain.jar --add-modules modb pkgcpmain.MainCallingModB 2>&1 | normalize | tee -a "${result_dir}/run.txt" | myecho; then
  echo "ERROR: Variant 20 - Expected success but got exception"
  exit 1
fi
