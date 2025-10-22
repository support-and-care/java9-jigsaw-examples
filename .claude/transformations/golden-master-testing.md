# Golden Master Testing Transformation

## Overview

This transformation implements golden master testing (also called characterization testing) for Java 9 Jigsaw examples. This ensures runtime behavior remains consistent during refactoring and transformations (e.g., Maven migration, compile/package separation).

## Motivation

With 40+ examples requiring transformation to Maven-based builds with separated compile and package steps, we need automated verification that runtime behavior hasn't changed. Manual comparison of outputs is:
- Time-consuming
- Error-prone
- Not scalable

Golden master testing solves this by:
- Capturing expected output once
- Automatically comparing future runs against it
- Detecting any behavioral changes immediately
- Providing confidence during refactoring

## Implementation Approach

### Per-Example Scripts

Each example that implements golden master testing includes three new scripts:

#### 1. `create-expected-result.sh`
Creates the golden master (expected output).

```bash
#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

EXAMPLE_NAME="$(basename "$(pwd)")"
echo "=== Creating expected result for ${EXAMPLE_NAME} ==="
echo

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create expected-result directory if it doesn't exist
mkdir -p expected-result

# Run the Java code and capture output
echo "Running Java module and capturing output..."
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main > expected-result/run.txt 2>&1

echo "✅ Expected result saved to expected-result/run.txt"
echo
echo "Contents:"
cat expected-result/run.txt
```

**Key points:**
- Shows Java version for debugging (not captured in output)
- Respects `${JAVA_OPTIONS}` for flexibility
- Captures both stdout and stderr
- Creates `expected-result/run.txt` (committed to git)

#### 2. `run.sh` (Modified)
Updated to capture output while still displaying it.

```bash
#!/usr/bin/env bash
set -eu -o pipefail

source ../env.sh

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create run-result directory if it doesn't exist
mkdir -p run-result

# Run the Java code, save output to run-result/run.txt, and display with highlighting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main 2>&1 | tee run-result/run.txt | myecho
```

**Changes:**
- Added Java version display (not captured)
- Uses `tee` to capture output to `run-result/run.txt`
- Still pipes through `myecho` for error highlighting
- Creates `run-result/` directory (gitignored)

#### 3. `verify.sh`
Compares actual vs expected output.

```bash
#!/usr/bin/env bash
set -eu -o pipefail

EXAMPLE_NAME="$(basename "$(pwd)")"
EXPECTED="expected-result/run.txt"
ACTUAL="run-result/run.txt"

# Parse command line arguments
ONLY_VERIFY=false
if [ "${1:-}" = "--only" ]; then
  ONLY_VERIFY=true
fi

echo "=== Verifying ${EXAMPLE_NAME} ==="
echo

# Check if expected result exists
if [ ! -f "${EXPECTED}" ]; then
  echo "❌ ERROR: Expected result not found at ${EXPECTED}"
  echo "   Run ./create-expected-result.sh first to create the golden master"
  exit 1
fi

# Perform full build unless --only is specified
if [ "${ONLY_VERIFY}" = false ]; then
  echo "Step 1: Clean"
  ./clean.sh
  echo

  echo "Step 2: Compile"
  ./compile.sh
  echo

  echo "Step 3: Run and capture output"
  ./run.sh
  echo
else
  echo "Skipping clean and compile (--only mode)"
  echo

  # Check if actual result exists
  if [ ! -f "${ACTUAL}" ]; then
    echo "❌ ERROR: Actual result not found at ${ACTUAL}"
    echo "   Run ./run.sh first to generate the actual output"
    exit 1
  fi
fi

# Compare the files
echo "Step 4: Compare expected vs actual output"
if diff -u "${EXPECTED}" "${ACTUAL}"; then
  echo
  echo "✅ SUCCESS: Output matches expected result"
  exit 0
else
  echo
  echo "❌ FAILURE: Output differs from expected result"
  echo "   Expected: ${EXPECTED}"
  echo "   Actual:   ${ACTUAL}"
  exit 1
fi
```

**Features:**
- **Default mode**: Clean → Compile → Run → Compare (full verification)
- **`--only` mode**: Skip build, only compare existing results (fast)
- Clear error messages with guidance
- Proper exit codes (0 = success, 1 = failure)

#### 4. `clean.sh` (Modified)
Updated to remove actual results.

```bash
rm -rf run-result
```

### Directory Structure

After implementing golden master testing:

```
example_<name>/
├── src/                           # Source code
├── expected-result/               # Golden masters (committed to git)
│   └── run.txt                   # Expected output
├── run-result/                    # Actual results (gitignored)
│   └── run.txt                   # Actual output from latest run
├── .gitignore                     # Updated to ignore run-result/
├── clean.sh                       # Updated to remove run-result/
├── compile.sh                     # Unchanged
├── run.sh                         # Modified to capture output
├── create-expected-result.sh     # NEW: Create golden master
└── verify.sh                      # NEW: Verify actual vs expected
```

### Global Orchestrator Scripts

Two new scripts in `jigsaw-examples/` directory:

#### 1. `all-create-expected-results.sh`
Creates golden masters for all examples that have the script.

```bash
#!/usr/bin/env bash
create_expected_result() {
    MODDIR=${dir%*/}
    pushd "${MODDIR}" > /dev/null 2>&1 || exit
    if [ -f ./create-expected-result.sh ]
    then
        echo "###################################################################################################################################"
        echo "Creating expected result for ${MODDIR}"
        ./create-expected-result.sh
        echo " "
    fi
    popd >/dev/null 2>&1 || exit
}

for dir in example_*/;
do
    create_expected_result
done
```

#### 2. `allverify.sh`
Verifies all examples with summary report.

```bash
#!/usr/bin/env bash
set -eu -o pipefail

# Arrays to track results
VERIFIED=()
FAILED=()
SKIPPED=()

verify() {
    MODDIR=${dir%*/}
    pushd "${MODDIR}" > /dev/null 2>&1 || exit
    if [ -f ./verify.sh ]
    then
        echo "###################################################################################################################################"
        echo "Verifying ${MODDIR}"
        if ./verify.sh "$@"
        then
            VERIFIED+=("${MODDIR}")
        else
            FAILED+=("${MODDIR}")
        fi
        echo " "
    else
        SKIPPED+=("${MODDIR}")
    fi
    popd >/dev/null 2>&1 || exit
}

for dir in example_*/;
do
    verify "$@"
done

# Print summary
echo "###################################################################################################################################"
echo "=== Verification Summary ==="
echo
echo "✅ Verified: ${#VERIFIED[@]}"
for example in "${VERIFIED[@]}"; do
    echo "   - ${example}"
done
echo

if [ ${#FAILED[@]} -gt 0 ]; then
    echo "❌ Failed: ${#FAILED[@]}"
    for example in "${FAILED[@]}"; do
        echo "   - ${example}"
    done
    echo
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
    echo "⊘ Skipped (no verify.sh): ${#SKIPPED[@]}"
    for example in "${SKIPPED[@]}"; do
        echo "   - ${example}"
    done
    echo
fi

# Exit with error if any failed
if [ ${#FAILED[@]} -gt 0 ]; then
    exit 1
fi
```

**Features:**
- Passes arguments to `verify.sh` (e.g., `./allverify.sh --only`)
- Tracks verified, failed, and skipped examples
- Comprehensive summary at end
- Returns exit code 1 if any examples failed

## Environment Configuration

### `env.sh` Changes

**Important:** `JAVA_OPTIONS` should not include output-producing flags:

```bash
# NOTE: Be careful with JAVA_OPTIONS that produce output (like -showversion, -XshowSettings, etc.)
# as they will affect golden master test result comparison in examples using verify.sh
export JAVAC_OPTIONS="-Xlint"
export JAVA_OPTIONS=""
export JAR_OPTIONS=""
```

**Rationale:**
- Flags like `-showversion`, `-XshowSettings`, `-Xlog:module=trace` produce output
- This output varies by JVM version and would break golden master comparison
- Java version is displayed separately in scripts for user information
- `${JAVA_OPTIONS}` remains available for scenarios where custom options are needed

## Handling Non-Deterministic Output

### Problem: Memory Addresses in toString()

Java's default `toString()` includes memory addresses:
```
pkgmain.Main@3af49f1c
```

These addresses change between runs, breaking comparison.

### Solution: Override toString()

Add deterministic `toString()` methods to classes that are printed:

```java
public class Main {
    // ... existing code ...

    @Override
    public String toString() {
        return getClass().getName();
    }
}
```

**Output before:** `pkgmain.Main@3af49f1c`
**Output after:** `pkgmain.Main`

### When to Apply This

Override `toString()` in classes that are:
- Directly printed via `System.out.println()`
- Converted to String via `toString()`
- Logged or output in any way

**Do NOT modify:**
- Classes not involved in output
- Test classes
- Internal implementation classes

## CI/CD Integration

### GitHub Actions Workflow

Add verification step after "Run all Samples":

```yaml
- name: Run all Samples
  shell: bash
  run: |
    source .envrc
    cd jigsaw-examples
    ./allrun.sh

- name: Verify all Samples
  shell: bash
  run: |
    source .envrc
    cd jigsaw-examples
    ./allverify.sh --only
```

**Why `--only` in CI?**
- CI already runs `allcompile.sh` and `allrun.sh`
- No need to rebuild in verification step
- Faster CI runs
- Still validates output correctness

### Workflow Execution

CI pipeline flow:
1. **Compile all Samples** → Builds everything
2. **Run all Samples** → Executes and captures output to `run-result/`
3. **Verify all Samples** → Compares `run-result/` vs `expected-result/`

If verification fails:
- CI job fails
- Diff output shows what changed
- Developers can investigate behavioral change

## Step-by-Step Implementation Guide

### For Each Example

#### Step 1: Create Scripts

Copy template scripts:
```bash
cd example_<name>

# Create create-expected-result.sh
cat > create-expected-result.sh << 'EOF'
# ... (use template above) ...
EOF
chmod +x create-expected-result.sh

# Create verify.sh
cat > verify.sh << 'EOF'
# ... (use template above) ...
EOF
chmod +x verify.sh
```

#### Step 2: Modify run.sh

Update to capture output using `tee`:
```bash
# Before
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main 2>&1 | myecho

# After
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

mkdir -p run-result
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main 2>&1 | tee run-result/run.txt | myecho
```

#### Step 3: Update clean.sh

Add removal of actual results:
```bash
rm -rf run-result
```

#### Step 4: Update .gitignore

Ignore actual results, commit expected results:
```bash
echo "/run-result/" >> .gitignore
```

#### Step 5: Fix Non-Deterministic Output

Identify classes that are printed and add `toString()`:
```java
@Override
public String toString() {
    return getClass().getName();
}
```

#### Step 6: Create Golden Master

```bash
# Compile first
./compile.sh

# Create golden master
./create-expected-result.sh
```

#### Step 7: Verify Implementation

```bash
# Full verification (clean build)
./verify.sh

# Should output: ✅ SUCCESS: Output matches expected result
```

#### Step 8: Test --only Mode

```bash
# Quick verification (existing build)
./verify.sh --only

# Should output: ✅ SUCCESS: Output matches expected result
```

#### Step 9: Test Failure Detection

```bash
# Modify expected result to test failure detection
echo "MODIFIED" >> expected-result/run.txt
./verify.sh --only

# Should output: ❌ FAILURE: Output differs from expected result
# Restore: git checkout expected-result/run.txt
```

#### Step 10: Commit Changes

```bash
git add .gitignore \
        clean.sh \
        run.sh \
        create-expected-result.sh \
        verify.sh \
        expected-result/ \
        src/  # If toString() was added

git commit -m "Add golden master testing for example_<name>"
```

## Common Patterns and Solutions

### Pattern 1: Multiple Run Scripts

Some examples have multiple `run*.sh` scripts (e.g., `run1.sh`, `run2.sh`).

**Solution:** Create multiple golden masters:
```bash
expected-result/
├── run1.txt
├── run2.txt
└── run3.txt
```

Update `verify.sh` to check all outputs.

### Pattern 2: Examples with No Output

Some examples don't produce stdout output.

**Options:**
1. Skip golden master testing (not all examples need it)
2. Capture other artifacts (e.g., generated files)
3. Add diagnostic output if meaningful

### Pattern 3: Platform-Specific Output

Output differs between OS (Linux/macOS/Windows).

**Solutions:**
1. **Normalize output:** Strip platform-specific paths, line endings
2. **Platform-specific golden masters:** `expected-result/run-linux.txt`, etc.
3. **Make code platform-independent:** Preferred when possible

### Pattern 4: Maven/Gradle Examples

Maven and Gradle produce verbose build output.

**Recommendation:**
- Don't capture full build output (too verbose, version-dependent)
- Only capture application output
- Run Maven/Gradle separately from golden master capture

## Troubleshooting

### Issue: Verification Fails After Clean Build

**Symptom:**
```
❌ FAILURE: Output differs from expected result
```

**Causes:**
1. Non-deterministic output (memory addresses, timestamps, UUIDs)
2. Different Java version
3. Different environment (paths, system properties)

**Solutions:**
1. Add `toString()` overrides for deterministic output
2. Document required Java version
3. Normalize paths/environment-specific output

### Issue: Expected Result Not Found

**Symptom:**
```
❌ ERROR: Expected result not found at expected-result/run.txt
```

**Solution:**
```bash
# Create the golden master first
./create-expected-result.sh
git add expected-result/
```

### Issue: Actual Result Not Found in --only Mode

**Symptom:**
```
❌ ERROR: Actual result not found at run-result/run.txt
```

**Solution:**
```bash
# Run the example first
./run.sh

# Then verify
./verify.sh --only
```

### Issue: Output Varies Between Runs

**Investigation:**
```bash
# Run multiple times and compare
./run.sh > output1.txt
./run.sh > output2.txt
diff output1.txt output2.txt
```

**Common causes:**
- Memory addresses (`@hexdigits`) → Add `toString()`
- Timestamps → Make deterministic or strip in verification
- Random values → Use fixed seed or remove randomness
- Threading/concurrency → Add ordering/synchronization

## Benefits of This Approach

1. **Automated Regression Detection**
   - Catches behavioral changes immediately
   - No manual inspection needed

2. **Confidence During Refactoring**
   - Can transform examples safely
   - Any output change is detected

3. **Documentation**
   - Golden masters document expected behavior
   - Serve as executable specifications

4. **Scalable**
   - Works for all 40+ examples
   - Orchestrator scripts handle bulk operations

5. **CI Integration**
   - Automatic verification on every push
   - Cross-platform validation (Linux/macOS/Windows)

6. **Low Maintenance**
   - Golden masters only updated when behavior intentionally changes
   - Scripts are simple and robust

## Limitations and Considerations

1. **Not a Replacement for Unit Tests**
   - Golden masters test overall behavior
   - Unit tests verify specific functionality
   - Both are valuable

2. **Initial Setup Required**
   - Each example needs scripts added
   - Non-determinism must be fixed
   - One-time investment pays off

3. **Brittleness to Intentional Changes**
   - If output format changes intentionally, golden master must be updated
   - This is by design (forces explicit approval of changes)

4. **Not All Examples Need This**
   - Some examples don't produce output
   - Some are build-only demonstrations
   - Apply where it adds value

## Future Enhancements

Possible improvements to consider:

1. **Output Normalization**
   - Automatic stripping of memory addresses
   - Path normalization
   - Timestamp replacement

2. **Multiple Golden Masters**
   - Per-platform expected results
   - Per-Java-version expected results

3. **Partial Matching**
   - Regex-based comparison
   - Ignore certain lines/patterns

4. **Visual Diff**
   - HTML diff reports in CI
   - Side-by-side comparison

5. **Performance Benchmarks**
   - Track execution time
   - Detect performance regressions

## References

- **Characterization Testing:** Working Effectively with Legacy Code (Michael Feathers)
- **Approval Testing:** Similar concept in test automation
- **Snapshot Testing:** React/Jest approach to component testing

## Example: example_requires_exports

Complete implementation in `jigsaw-examples/example_requires_exports/` demonstrates all concepts covered in this guide.