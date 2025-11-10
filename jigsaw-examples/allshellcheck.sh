#!/usr/bin/env bash
set -eu -o pipefail

echo "=== Running shellcheck on shell scripts ==="
echo

# Track errors
error_count=0

# Function to run shellcheck on a script
# Returns 0 on success, 1 on failure
check_script() {
    local script_path="$1"
    local script_dir
    local script_name
    local output
    local exit_code

    script_dir="$(dirname "${script_path}")"
    script_name="$(basename "${script_path}")"

    # Run shellcheck from the script's directory to enable -x flag
    # Capture output to avoid printing directory changes
    output=$(cd "${script_dir}" 2>/dev/null && shellcheck -x "${script_name}" 2>&1)
    exit_code=$?

    if [ ${exit_code} -eq 0 ]; then
        echo "✓ ${script_path}"
        return 0
    else
        echo "❌ Failed: ${script_path}"
        # Show the actual errors
        echo "${output}"
        return 1
    fi
}

echo "Checking all*.sh scripts in jigsaw-examples/..."
echo
for script in all*.sh; do
    if [ -f "${script}" ]; then
        check_script "${script}" || error_count=$((error_count + 1))
    fi
done

echo
echo "Checking clean*.sh, compile*.sh, run*.sh, and verify*.sh scripts in examples..."
echo
for example_dir in example_*/; do
    if [ -d "${example_dir}" ]; then
        # Check clean*.sh
        for clean_script in "${example_dir}"clean*.sh; do
            if [ -f "${clean_script}" ]; then
                check_script "${clean_script}" || error_count=$((error_count + 1))
            fi
        done

        # Check compile*.sh
        for compile_script in "${example_dir}"compile*.sh; do
            if [ -f "${compile_script}" ]; then
                check_script "${compile_script}" || error_count=$((error_count + 1))
            fi
        done

        # Check run*.sh
        for run_script in "${example_dir}"run*.sh; do
            if [ -f "${run_script}" ]; then
                check_script "${run_script}" || error_count=$((error_count + 1))
            fi
        done

        # Check verify*.sh
        for verify_script in "${example_dir}"verify*.sh; do
            if [ -f "${verify_script}" ]; then
                check_script "${verify_script}" || error_count=$((error_count + 1))
            fi
        done
    fi
done

echo
echo "Checking m4/*.sh scripts in examples..."
echo
for example_dir in example_*/; do
    if [ -d "${example_dir}m4" ]; then
        for m4_script in "${example_dir}"m4/*.sh; do
            if [ -f "${m4_script}" ]; then
                check_script "${m4_script}" || error_count=$((error_count + 1))
            fi
        done
    fi
done

echo
echo "=== Shellcheck Summary ==="
if [ ${error_count} -eq 0 ]; then
    echo "✅ All scripts passed shellcheck"
    exit 0
else
    echo "❌ ${error_count} script(s) failed shellcheck"
    exit 1
fi
