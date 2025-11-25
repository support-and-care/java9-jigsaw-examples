#!/usr/bin/env bash
set -eu -o pipefail

echo "=== Verifying source file consistency between ../src and m4/src ==="
echo

# Track if any differences found
DIFFERENCES_FOUND=0

# Find all files in ../src (excluding .gitignore)
while IFS= read -r -d '' srcfile; do
  # Get relative path from ../src
  relpath="${srcfile#../src/}"

  # Extract module name (first directory component)
  module="${relpath%%/*}"

  # Get path after module name
  pathInModule="${relpath#*/}"

  # Determine if it's a Java file or resource file
  if [[ "${pathInModule}" == *.java ]]; then
    # Java file: should be in src/{module}/main/java/{path}
    m4file="src/${module}/main/java/${pathInModule}"
  else
    # Resource file: should be in src/{module}/main/resources/{path}
    m4file="src/${module}/main/resources/${pathInModule}"
  fi

  # Check if m4 file exists
  if [[ ! -f "${m4file}" ]]; then
    echo "ERROR: Missing file in m4/src: ${m4file}"
    echo "       Expected from: ${srcfile}"
    DIFFERENCES_FOUND=1
    continue
  fi

  # Compare file contents
  if ! diff -q "${srcfile}" "${m4file}" > /dev/null 2>&1; then
    echo "ERROR: File content differs:"
    echo "       Source: ${srcfile}"
    echo "       M4:     ${m4file}"
    echo "       Diff:"
    diff -u "${srcfile}" "${m4file}" | head -20
    DIFFERENCES_FOUND=1
  fi
done < <(find ../src -type f ! -name '.gitignore' -print0)

# Check for extra files in m4/src that don't exist in ../src
while IFS= read -r -d '' m4file; do
  # Get relative path from src/
  relpath="${m4file#src/}"

  # Extract module name and determine original structure
  if [[ "${relpath}" =~ ^([^/]+)/main/java/(.+)$ ]]; then
    module="${BASH_REMATCH[1]}"
    pathInModule="${BASH_REMATCH[2]}"
    srcfile="../src/${module}/${pathInModule}"
  elif [[ "${relpath}" =~ ^([^/]+)/main/resources/(.+)$ ]]; then
    module="${BASH_REMATCH[1]}"
    pathInModule="${BASH_REMATCH[2]}"
    srcfile="../src/${module}/${pathInModule}"
  else
    echo "WARNING: Unexpected file structure: ${m4file}"
    continue
  fi

  # Check if source file exists
  if [[ ! -f "${srcfile}" ]]; then
    echo "ERROR: Extra file in m4/src not present in ../src:"
    echo "       M4:     ${m4file}"
    echo "       Source: ${srcfile} (expected but not found)"
    DIFFERENCES_FOUND=1
  fi
done < <(find src -type f ! -name '.gitignore' -print0)

echo
if [[ ${DIFFERENCES_FOUND} -eq 0 ]]; then
  echo "✅ All source files are consistent between ../src and m4/src"
  exit 0
else
  echo "❌ Differences found between ../src and m4/src"
  exit 1
fi
