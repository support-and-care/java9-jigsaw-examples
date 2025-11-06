# Maven 4 Migration Strategy

## Overview

This guide documents the strategy for migrating Jigsaw examples to Maven 4, enabling experimentation with different build approaches while maintaining source code as single source of truth through symbolic linking.

## Goals

- Migrate examples to Maven 4 incrementally, example by example
- Allow multiple build approach experiments per example (Maven 3, Maven 4, Gradle variants)
- Maintain source code in original locations (single source of truth)
- Use symbolic links to reference sources from Maven-standard directory structure
- Create minimal, standalone Maven projects for each migration
- Integrate with existing golden master testing framework
- Ensure Maven 4 is consistently used via `M4_HOME` environment variable
- Keep m4 scripts as close as possible to original scripts for comparability
- Target Java 11 bytecode while using JDK 17 to run Maven 4

## Key Learnings from Test Migration

Based on successful migration of `example_requires-static`:

### Maven 4 Requirements

1. **Model Version**: Must use `<modelVersion>4.1.0</modelVersion>` (not 4.0.0)
2. **Compiler Plugin**: Must use `maven-compiler-plugin` version `4.0.0-beta-3` (not 3.x)
3. **Maven Runtime**: Maven 4 requires Java 17+ to run
4. **Compilation Target**: Use `<maven.compiler.release>11</maven.compiler.release>` to produce Java 11 bytecode
5. **POM Namespace**: Use `http://maven.apache.org/POM/4.1.0` schema

### Script Design Principles

1. **Stay Close to Original**: m4 scripts should mirror original script structure for easy comparison
2. **Complete Separation**: Build artifacts go to `m4/mlib` (not `../mlib`) for complete isolation
3. **M4_HOME Only in compile.sh**: Only needed where Maven is invoked, not in run.sh
4. **Shellcheck Compliance**: All scripts must pass shellcheck (with documented exceptions)
5. **Golden Master Integration**: verify.sh should match original verify.sh pattern

### JDK Version Strategy

- **Maven Execution**: Use JDK 17 (from JAVA17_HOME) to run Maven 4
- **Compilation**: Maven uses JDK 17 compiler with `--release 11` flag
- **Runtime**: Use JDK 11 (from JAVA_HOME) to run the application
- **Verification**: Check bytecode with `javap -v`: major version 55 = Java 11

This approach is simpler than Maven Toolchains and produces correct Java 11 compatible bytecode.

## Directory Structure

Each migrated example will have a subdirectory for each build approach:

```
example_foo/
├── src/                          # Original source location (single source of truth)
│   ├── moda/
│   │   ├── module-info.java
│   │   └── pkga/
│   └── modb/
│       ├── module-info.java
│       └── pkgb/
├── compile.sh                    # Original compilation script
├── run.sh                        # Original run script
├── m4/                           # Maven 4 migration subdirectory
│   ├── pom.xml                   # Maven 4 specific POM (standalone, minimal)
│   ├── src/
│   │   └── java/                 # Maven 4 Module Source Hierarchy
│   │       ├── moda/
│   │       │   └── main -> ../../../../src/moda  # Symlink to module source
│   │       └── modb/
│   │           └── main -> ../../../../src/modb  # Symlink to module source
│   ├── mlib/                     # Module JARs (separate from ../mlib)
│   ├── run-result/               # Runtime output (for verification)
│   ├── target/                   # Maven build output
│   ├── .gitignore                # Ignore build artifacts (target/, mlib/, run-result/)
│   ├── clean.sh                  # Clean m4 artifacts
│   ├── compile.sh                # Maven compile + jar packaging
│   ├── run.sh                    # Execution (uses m4/mlib)
│   ├── verify.sh                 # Golden master verification
│   └── javadoc.sh               # Maven javadoc wrapper (optional)
├── m3/                           # (Future) Maven 3 alternative approach
└── gradle-alt/                   # (Future) Alternative Gradle approach
```

## Symbolic Link Strategy

**Always use relative paths for portability across systems.**

We use the **Module Source Hierarchy** approach, which explicitly declares each module in the directory structure and POM configuration.

### Standard Links (Module Source Hierarchy)

For examples with multiple modules in `src/`:

```bash
cd example_foo/m4

# Create structure for first module (e.g., modmain)
mkdir -p src/java/modmain
ln -s ../../../../src/modmain src/java/modmain/main

# Create structure for second module (e.g., modb)
mkdir -p src/java/modb
ln -s ../../../../src/modb src/java/modb/main
```

This creates:
- `m4/src/java/modmain/main` → `../../../../src/modmain`
- `m4/src/java/modb/main` → `../../../../src/modb`

### Single Module Examples

For examples with a single module:

```bash
cd example_foo/m4
mkdir -p src/java/modmain
ln -s ../../../../src/modmain src/java/modmain/main
```

### Test Links

For examples with tests (rare, but exists):

```bash
cd example_foo/m4
mkdir -p src/java/modmain
ln -s ../../../../test/modmain src/java/modmain/test
```

This creates: `m4/src/java/modmain/test` → `../../../../test/modmain`

### Resources

If examples have module-specific resources:

```bash
cd example_foo/m4
mkdir -p src/java/modmain/main
ln -s ../../../../../resources/modmain src/java/modmain/main/resources
```

**Note**: Resource structure depends on original example layout - inspect before creating links.

### Rationale

- **Relative paths**: Ensures repository remains relocatable
- **Single source of truth**: All source modifications happen in original `src/` location
- **No duplication**: Reduces maintenance burden and prevents divergence
- **Explicit module declaration**: Maven 4 Module Source Hierarchy makes module structure clear
- **Automatic JPMS arguments**: Compiler automatically adds necessary module compilation flags

## Maven Project Structure

### Standalone Projects

Each `m4` subdirectory is a **standalone, minimal Maven project**:

- Single `pom.xml` in `m4/` directory
- No parent/reactor POMs
- No inter-example dependencies through Maven (use file-based module-path if needed)
- Minimal configuration - only what's needed for that specific example

### Maven 4 Source Directory Configuration

**Reference**: [Maven Compiler Plugin Migration Guide - Declaration of Source Directories](https://github.com/Geomatys/maven-compiler-plugin/wiki/Migration#declaration-of-source-directories)

Maven 4 introduces a new `<sources>` element that **replaces the default values**. This means you must explicitly declare all source directories.

#### Module Source Hierarchy (Recommended)

We use this approach for explicit module declaration and better JPMS integration:

```xml
<build>
  <sources>
    <source>
      <module>modmain</module>
      <directory>src/java/modmain/main</directory>
    </source>
    <source>
      <module>modb</module>
      <directory>src/java/modb/main</directory>
    </source>
    <!-- Add test sources if example has tests -->
    <source>
      <module>modmain</module>
      <scope>test</scope>
      <directory>src/java/modmain/test</directory>
    </source>
  </sources>
</build>
```

**Benefits**:
- **Explicit module declaration**: Each module is clearly identified in the POM
- **Automatic JPMS compiler arguments**: Maven automatically adds necessary module compilation flags
- **Better multi-module organization**: Clear separation of modules in directory structure
- **Future-proof**: Aligns with Maven 4's module-aware design

**For our migration**: We'll use the **Module Source Hierarchy** approach with symbolic links pointing from the Maven 4 structure to the original source locations.

#### Package Hierarchy Approach (Alternative, Maven 3 Compatible)

This approach maintains traditional directory structure:

```xml
<build>
  <sources>
    <source>
      <directory>src/main/java</directory>
    </source>
    <source>
      <scope>test</scope>
      <directory>src/test/java</directory>
    </source>
  </sources>
</build>
```

**Benefits**:
- Compatible with Maven 3 conventions
- Tests handled via `module-info-patch.maven` (optional)
- Compiler automatically adds `--patch-module`, `--add-modules`, `--add-reads` for tests

**Note**: We're not using this approach to take full advantage of Maven 4's module-aware features.

### POM Requirements

Minimal POM should include (using Module Source Hierarchy):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.1.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.1.0
                             http://maven.apache.org/xsd/maven-4.1.0.xsd">
  <modelVersion>4.1.0</modelVersion>

  <groupId>com.example.jigsaw</groupId>
  <artifactId>example-foo-m4</artifactId>
  <version>1.0-SNAPSHOT</version>

  <properties>
    <maven.compiler.release>11</maven.compiler.release>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <build>
    <sources>
      <!-- Declare each module explicitly -->
      <source>
        <module>modmain</module>
        <directory>src/java/modmain/main</directory>
      </source>
      <source>
        <module>modb</module>
        <directory>src/java/modb/main</directory>
      </source>
      <!-- Add test sources if example has tests -->
      <source>
        <module>modmain</module>
        <scope>test</scope>
        <directory>src/java/modmain/test</directory>
      </source>
    </sources>

    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>4.0.0-beta-3</version>
      </plugin>
    </plugins>
  </build>
</project>
```

**Note**:
- **MUST use `<modelVersion>4.1.0</modelVersion>`** (not 4.0.0) with Maven 4
- **MUST use `maven-compiler-plugin` version `4.0.0-beta-3`** (not 3.x) for Maven 4 support
- Use `maven.compiler.release=11` to target Java 11 bytecode (while running Maven with JDK 17)
- The `<sources>` element is **required** in Maven 4 and replaces default source directories
- Each module must be explicitly declared with `<module>` and `<directory>`
- Module names must match the module names in `module-info.java`
- Test sources declaration can be omitted if example has no tests

## Script Integration

### Script Conventions

All wrapper scripts in `m4/` must follow repository shell scripting conventions:

```bash
#!/usr/bin/env bash
set -eu -o pipefail

# Script content here
```

See main `CLAUDE.md` for full shell scripting conventions (quoting, TMPDIR, etc.).

### compile.sh - Compilation Wrapper

**Phase 1: Hybrid Approach (Initial Migration)**

Use Maven 4 for compilation, but traditional `jar` command for packaging:

```bash
#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Ensure we're using Maven 4
if [ -z "${M4_HOME:-}" ]; then
  echo "ERROR: M4_HOME is not set. Please configure it in .envrc or env.sh"
  exit 1
fi

# Maven 4 requires Java 17+ to run
# Note: pom.xml has <maven.compiler.release>11</maven.compiler.release> which ensures
# Java 11 compatible bytecode even when using JDK 17 compiler with --release 11
if [ -n "${JAVA17_HOME:-}" ]; then
  export JAVA_HOME="${JAVA17_HOME}"
fi

# Add Maven 4 to PATH
export PATH="${M4_HOME}/bin:${PATH}"

mkdir -p mlib

echo "mvn --version"
mvn --version
echo

echo "mvn clean compile"
echo "(Maven runs with JDK 17, compiles for Java 11 via maven.compiler.release)"
mvn clean compile

# Create JARs directly to mlib (similar to original compile.sh)
pushd target/classes > /dev/null 2>&1
for dir in */;
do
    MODDIR=${dir%*/}
    echo "jar $JAR_OPTIONS --create --file=../../mlib/${MODDIR}.jar -C ${MODDIR} ."
    # shellcheck disable=SC2086  # JAR_OPTIONS is intentionally unquoted for word splitting
    "${JAVA_HOME}/bin/jar" $JAR_OPTIONS --create --file="../../mlib/${MODDIR}.jar" -C "${MODDIR}" . 2>&1
done
popd >/dev/null 2>&1
```

**Note**:
- Script uses JDK 17 to run Maven 4 (required)
- Compiles for Java 11 target via `maven.compiler.release=11`
- Creates JARs directly to `mlib/` (not `../mlib/`) for complete separation
- Uses same JAR creation pattern as original compile.sh

**Phase 2: Full Maven (Future)**

Once Maven plugins prove compatible with JPMS:

```bash
#!/usr/bin/env bash
set -eu -o pipefail

echo "=== Maven 4 Compile (Full Maven) ==="
echo
mvn --version
echo
mvn clean package
echo "✅ Build complete"
```

### run.sh - Execution Wrapper

Execute the example using artifacts from Maven build (stays close to original run.sh):

```bash
#!/usr/bin/env bash
set -eu -o pipefail

# shellcheck source=../../env.sh
source ../../env.sh

# Show Java version for user information
echo "Using Java version:"
"${JAVA_HOME}/bin/java" -version
echo

# Create run-result directory if it doesn't exist
mkdir -p run-result

# Example: adjust module-path to use m4/mlib and preserve original runtime flags
# shellcheck disable=SC2086  # JAVA_OPTIONS is intentionally unquoted for word splitting
"${JAVA_HOME}/bin/java" ${JAVA_OPTIONS} --module-path mlib --module modmain/pkgmain.Main 2>&1 | normalize | tee run-result/run.txt | myecho
```

**Important**:
- Copy structure from original `run.sh` to stay close to original
- Use `mlib` (not `../mlib`) since artifacts are in m4/mlib
- Preserve any special JVM flags from original (--add-exports, --add-reads, --add-modules, etc.)
- No M4_HOME needed here - only Maven runtime uses it
- Output to `run-result/run.txt` for golden master verification

### verify.sh - Golden Master Integration

Integrate with existing golden master testing framework (matches original pattern):

```bash
#!/usr/bin/env bash
set -eu -o pipefail

EXAMPLE_NAME="$(basename "$(dirname "$(pwd)")")"
EXPECTED="../expected-result/run.txt"
ACTUAL="run-result/run.txt"

# Parse command line arguments
ONLY_VERIFY=false
if [ "${1:-}" = "--only" ]; then
  ONLY_VERIFY=true
fi

echo "=== Verifying ${EXAMPLE_NAME} (Maven 4) ==="
echo

# Check if expected result exists
if [ ! -f "${EXPECTED}" ]; then
  echo "❌ ERROR: Expected result not found at ${EXPECTED}"
  echo "   Run ../create-expected-result.sh first to create the golden master"
  exit 1
fi

# Perform full build unless --only is specified
if [ "${ONLY_VERIFY}" = false ]; then
  echo "Step 1: Compile"
  ./compile.sh
  echo

  echo "Step 2: Run and capture output"
  ./run.sh
  echo
else
  echo "Skipping compile (--only mode)"
  echo

  # Check if actual result exists
  if [ ! -f "${ACTUAL}" ]; then
    echo "❌ ERROR: Actual result not found at ${ACTUAL}"
    echo "   Run ./run.sh first to generate the actual output"
    exit 1
  fi
fi

# Compare the files
echo "Step 3: Compare expected vs actual output"
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

**Notes**:
- Matches original verify.sh pattern (including --only flag support)
- Compares `run-result/run.txt` with `../expected-result/run.txt`
- No TMPDIR needed - output already in run-result/

### clean.sh - Cleanup Script

Clean all m4 build artifacts:

```bash
#!/usr/bin/env bash
rm -rf target
rm -rf mlib
rm -rf run-result
```

**Note**: Simple cleanup matching original pattern - removes Maven output, JARs, and runtime results

### javadoc.sh - Documentation Wrapper (Optional)

For examples where Javadoc generation is relevant:

```bash
#!/usr/bin/env bash
set -eu -o pipefail

echo "=== Maven 4 Javadoc ==="
mvn javadoc:javadoc
echo "✅ Javadoc generated in target/site/apidocs"
```

## Migration Process

### Step-by-Step Workflow

1. **Select Example**: Choose example to migrate (prioritization TBD)

2. **Inspect Original Scripts**: Read `compile.sh`, `run.sh` to understand:
   - Module structure
   - Compilation commands
   - JAR packaging commands
   - Runtime configuration
   - Any special flags or workarounds

3. **Create m4 Structure**:
   ```bash
   cd example_foo
   mkdir -p m4
   cd m4
   ```

4. **Create Symbolic Links** (Module Source Hierarchy):
   ```bash
   # For each module in the example, create structure and symlink
   # Example with two modules: modmain and modb

   mkdir -p src/java/modmain
   ln -s ../../../../src/modmain src/java/modmain/main

   mkdir -p src/java/modb
   ln -s ../../../../src/modb src/java/modb/main

   # Add test links if example has tests
   ln -s ../../../../test/modmain src/java/modmain/test
   ```

5. **Create .gitignore**:
   ```bash
   # Create .gitignore to exclude build artifacts
   cat > .gitignore << 'EOF'
target/
mlib/
run-result/
EOF
   ```

6. **Create pom.xml**:
   - Start with minimal POM template using Module Source Hierarchy
   - Include `<sources>` element with explicit `<module>` declarations (required in Maven 4)
   - Declare each module with matching `<module>` name and `<directory>` path
   - Add dependencies if needed
   - Configure compiler plugin for JPMS
   - Adjust release version per example requirements
   - Include test sources declaration if example has tests

6. **Create compile.sh**:
   - Follow hybrid approach (Maven compile + traditional jar)
   - Inspect original compile.sh for jar commands
   - Adapt paths to Maven's target/ structure
   - Copy JARs to ../mlib for compatibility

7. **Create run.sh**:
   - Copy module path configuration from original
   - Adjust paths to use ../mlib (populated by compile.sh)
   - Preserve any special JVM flags

8. **Create verify.sh**:
   - Integrate with golden master framework
   - Reuse existing expected-result.txt
   - Follow verification script pattern above

9. **Test Migration**:
   ```bash
   cd m4
   ./verify.sh
   ```

10. **Update Example README**: Add both Maven 4 output section and Maven 4 Migration section to the example's README.adoc:

    a. Add the Maven 4 output section (if not already present):
    ```adoc
    ==== Maven 4 Output

    [source]
    ----
    include::m4/run-result/run.txt[]
    ----
    ```

    b. Add the Maven 4 Migration section at the end of the README (level 2 heading):

    For straightforward migrations (standard POM with sources and compiler plugin):
    ```adoc
    == Maven 4 Migration

    This example was migrated to Maven 4 using the standard approach documented in the xref:../../README.adoc#maven-4-migration[central Maven 4 Migration guide].
    The migration required no special configuration beyond the standard Module Source Hierarchy setup.
    ```

    For migrations requiring special configuration (add-reads, add-exports, automatic modules, etc.):
    ```adoc
    == Maven 4 Migration

    This example required special handling when migrating to Maven 4.

    === Maven 4 Compiler Changes

    ==== The Challenge

    [Explain the specific challenge...]

    ==== The Solution

    [Provide the specific solution with code examples...]

    ==== Key Takeaways

    * [List key points...]
    ```

    This documents the migration completion and shows that Maven 4 produces equivalent output.
    For examples with special requirements, it provides valuable documentation for similar migrations.

11. **Document Issues**: Note any JPMS/Maven plugin compatibility issues for future resolution

### Example Selection Criteria

**Start with simpler examples** (prioritization TBD, but likely candidates):

- Examples with minimal module dependencies
- Examples without complex runtime configurations
- Examples already proven to work well (existing golden master tests pass)

**Defer complex examples**:

- Multi-module Maven projects (example_maven-*)
- Examples with layers or complex runtime setups
- Examples with automatic modules or classpath interop

## Known Challenges and Solutions

### Challenge: Module-Info Location

**Issue**: Maven expects module-info.java at specific location in source tree.

**Solution**: Module Source Hierarchy handles this explicitly - each module gets its own directory structure (e.g., `m4/src/java/modmain/main`) which symlinks to the original module source directory containing `module-info.java`.

### Challenge: Multi-Module Examples

**Issue**: Examples with multiple modules need multiple module-info.java files.

**Solution**: Module Source Hierarchy naturally supports this - each module is explicitly declared in both the directory structure and the POM's `<sources>` section:
```xml
<sources>
  <source>
    <module>modmain</module>
    <directory>src/java/modmain/main</directory>
  </source>
  <source>
    <module>modb</module>
    <directory>src/java/modb/main</directory>
  </source>
</sources>
```

Each symlink points to the corresponding module's source directory in the original structure.

### Challenge: Automatic Modules

**Issue**: Examples using automatic modules (amlib/) need those JARs on module-path.

**Solution**: Copy automatic module JARs to a location Maven can reference, or configure module-path in compiler plugin to include `../amlib`.

### Challenge: Test Module Configuration

**Issue**: Whitebox testing requires --patch-module or special configuration.

**Solution**: Configure maven-surefire-plugin with appropriate argLine for --patch-module or --add-reads/--add-exports.

### Challenge: Golden Master Compatibility

**Issue**: Output format might differ between traditional and Maven builds.

**Solution**: Ensure run.sh produces identical output. If needed, update expected-result.txt for Maven-specific approach (but document divergence).

## Integration with CLAUDE.md

Update main `CLAUDE.md` to reference this transformation guide:

```markdown
### Transformation Guides

Transformation-specific guides are stored in `.claude/transformations/` directory:

- **Maven 4 Migration**: `.claude/transformations/maven-4-migration.md` - Migrating examples to Maven 4 with hybrid compilation approach
```

## Future Enhancements

1. **Full Maven Phase**: Transition from hybrid (Maven compile + jar) to full Maven (package goal)
2. **Maven 3 Variants**: Create `m3/` subdirectories for Maven 3 comparison
3. **Gradle Variants**: Create `gradle-alt/` for alternative Gradle approaches
4. **CI/CD Integration**: Add GitHub Actions workflows for Maven 4 builds
5. **Plugin Testing Matrix**: Document which Maven plugins fully support JPMS

## Success Criteria

A migration is considered successful when:

1. `m4/verify.sh` passes (output matches golden master)
2. All scripts follow shell conventions from CLAUDE.md
3. Source code remains in original location (only symlinks in m4/)
4. POM is minimal and standalone
5. Build artifacts are functionally equivalent to original build

## Reference Examples

Once first examples are migrated, list them here as references:

- (TBD - will be populated as migrations complete)