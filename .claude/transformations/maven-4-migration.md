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
│   ├── compile.sh                # Maven compile wrapper
│   ├── run.sh                    # Maven run wrapper
│   ├── verify.sh                 # Maven verify wrapper (golden master integration)
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
<project>
  <modelVersion>4.0.0</modelVersion>
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
        <version>3.13.0</version>
      </plugin>
    </plugins>
  </build>
</project>
```

**Note**:
- Adjust compiler release version, dependencies, and plugins as needed per example
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

Use Maven for compilation, but traditional `jar` command for packaging:

```bash
#!/usr/bin/env bash
set -eu -o pipefail

echo "=== Maven 4 Compile (Hybrid) ==="
echo
echo "Step 0: Show Maven version"
mvn --version

echo
echo "Step 1: Compile with Maven"
mvn clean compile

echo
echo "Step 2: Package with jar command (traditional)"
# Inspect original compile.sh to find jar commands
# Adapt to use Maven's target/classes output
jar --create --file=target/moda.jar -C target/classes/moda .
jar --create --file=target/modb.jar -C target/classes/modb .

echo
echo "Step 3: Copy JARs to mlib (for compatibility with run.sh)"
mkdir -p ../mlib
cp target/*.jar ../mlib/

echo "✅ Compilation complete"
```

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

Execute the example using artifacts from Maven build:

```bash
#!/usr/bin/env bash
set -eu -o pipefail

: "${TMPDIR:=/tmp}"

echo "=== Maven 4 Run ==="

# Adjust module-path to use Maven outputs
java --module-path ../mlib \
     --module modmain/pkgmain.Main

echo "✅ Execution complete"
```

**Important**: Inspect original `run.sh` to understand:
- Module path configuration
- Main module and class
- Any special JVM flags (--add-exports, --add-reads, etc.)

### verify.sh - Golden Master Integration

Integrate with existing golden master testing framework:

```bash
#!/usr/bin/env bash
set -eu -o pipefail

: "${TMPDIR:=/tmp}"

EXAMPLE_NAME="$(basename "$(dirname "$(pwd)")")"
OUTPUT_FILE="${TMPDIR}/${EXAMPLE_NAME}-m4-output.txt"

echo "=== Verifying Maven 4 build for ${EXAMPLE_NAME} ==="

# Step 1: Compile
echo
echo "Step 1: Compile"
./compile.sh

# Step 2: Run and capture output
echo
echo "Step 2: Run and capture output"
./run.sh > "${OUTPUT_FILE}" 2>&1

# Step 3: Compare with golden master
echo
echo "Step 3: Compare with expected result"
if diff -u ../expected-result.txt "${OUTPUT_FILE}"; then
  echo "✅ Output matches expected result"
  exit 0
else
  echo "❌ Output differs from expected result"
  exit 1
fi
```

**Notes**:
- Reuses existing `expected-result.txt` from parent directory
- Captures both stdout and stderr
- Uses diff for comparison (same as existing verify.sh scripts)

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

5. **Create pom.xml**:
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

10. **Document Issues**: Note any JPMS/Maven plugin compatibility issues for future resolution

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