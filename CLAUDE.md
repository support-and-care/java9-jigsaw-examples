# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a comprehensive example suite demonstrating Java 9+ Jigsaw module system (Project Jigsaw/JSR 376/JEP 261). The repository contains 40+ independent examples, each illustrating specific aspects of the Java Platform Module System (JPMS).

## Transformation Workflow

When performing large-scale transformations or refactorings across the repository, follow this structured approach to ensure consistency and capture reusable patterns:

### Process

1. **Planning Phase**
   - Break down the transformation into discrete, manageable subtasks
   - Each subtask should target a single example or a logically grouped set of examples
   - Document the plan using TodoWrite tool to track progress

2. **Execution Phase**
   - Work through subtasks sequentially
   - Apply the transformation to each target
   - Observe and document any patterns, edge cases, or best practices that emerge
   - Update progress in the todo list

3. **Pattern Recognition Phase**
   - After completing each subtask, identify common patterns encountered
   - Document recurring issues and their solutions
   - Note any transformation-specific techniques that prove effective

4. **Documentation Phase**
   - Create or update a transformation-specific guide in `.claude/transformations/`
   - Each guide should capture:
     - Transformation objectives
     - Common patterns identified
     - Edge cases and how to handle them
     - Step-by-step procedures for applying the transformation
     - Example before/after code snippets
   - Reference the transformation guide from this CLAUDE.md file

### Transformation Guides

Transformation-specific guides are stored in `.claude/transformations/` directory:

- **Markdown to AsciiDoc Migration**: `.claude/transformations/markdown-to-asciidoc.md`
- Additional transformations will be documented as they are undertaken

Each guide serves as a living document that:
- Captures institutional knowledge from completed work
- Accelerates future similar transformations
- Ensures consistency across the codebase
- Provides troubleshooting reference for common issues

### Benefits

This approach ensures:
- Systematic completion of large-scale changes
- Knowledge capture for future reference
- Consistent application of patterns
- Reduced cognitive load through structured workflow
- Easier onboarding for future transformations

## Example Classification Guide

The examples can be classified along multiple dimensions to help you quickly find relevant examples:

### By Lifecycle Phase

**Compile-time:**
- `example_compile-target-jdk8` - Cross-compilation to different JDK versions
- `example_addReads_addExports` - Compile-time module boundary overrides
- `example_requires-static` - Optional compile-time dependencies

**Runtime:**
- `example_resolved-modules` - Module resolution and jlink
- `example_layer-modules-module-resolution` - Runtime module resolution in layers
- `example_addExports_manifest` - Runtime exports configuration via manifest
- `example_jerrymouse` - Dynamic module loading (module container)

**Test-time:**
- `example_test` - Blackbox and whitebox testing strategies
- `example_maven-test-blackbox` - Blackbox testing with Maven
- `example_maven-test-whitebox` - Whitebox testing with Maven using --patch-module
- `example_patch` - Module patching for testing and bugfixes

### By Module System Feature

**Module Declaration Basics:**
- `example_naming-modules` - Module naming rules and conventions
- `example_annotations` - Module annotations and deprecation
- `example_requires_exports` - Basic requires/exports declarations

**Dependency Management:**
- `example_requires-static` - Optional dependencies (compile-time only)
- `example_requires_exports_requires-transitive_exports-to` - Transitive dependencies
- `example_requires_exports-to` - Qualified (targeted) exports

**Visibility & Access Control:**
- `example_reflection` - Reflection in modular code
- `example_addReads_addExports_reflection` - Reflection with command-line overrides
- `example_hiddenmain` - Non-exported main classes
- `example_resources` - Module resource encapsulation

**Service Provider Interface (SPI):**
- `example_uses-provides` - Service provider pattern with uses/provides
- `example_uses-provides_uses-in-client` - Separating uses from service definition

**Module Layers:**
- `example_layer-hierarchy` - Creating layer hierarchies programmatically
- `example_layer-modules-all-in-boot-layer` - All modules in boot layer
- `example_layer-modules-grouped-in-hierarchy` - Distributing modules across layers
- `example_layer-modules-module-resolution` - Version resolution in layers
- `example_jerrymouse` - Module container/loader (plugin architecture)

### By Module Type

**Explicit Modules** (with module-info.java):
- Most examples demonstrate explicit modules

**Automatic Modules** (JARs without module-info on module-path):
- `example_automatic-module-logging` - Third-party JARs as automatic modules
- `example_splitpackage_automatic-modules` - Split package issues with automatic modules

**Unnamed Module** (classpath code):
- `example_unnamed-module_access-from-explicit-module` - Explicit module → classpath (NOT ALLOWED)
- `example_unnamed-module_access-from-automatic-module` - Automatic module → classpath (ALLOWED)
- `example_unnamed-module_access-from-explicit-module-reflection` - Reflection from explicit to unnamed
- `example_unnamed-module_accessing-module-path` - Classpath code accessing module-path
- `example_unnamed-module-reflection-illegal-access` - Classpath reflection to JDK internals

### By Build System

**Maven:**
- `example_maven-project` - Basic Maven multi-module build
- `example_maven-test-blackbox` - Maven with blackbox testing
- `example_maven-test-whitebox` - Maven with whitebox testing
- `example_spring-hibernate` - Real-world Spring Boot migration

**Gradle:**
- `example_gradle-project` - Gradle build for modular project

**Shell Scripts** (direct javac/java):
- All other examples use shell scripts with direct tool invocation

### By Problem Domain

**Common Pitfalls:**
- `example_derived_private-package-protected` - Exported types with non-exported supertypes
- `example_exceptions` - Non-exported exception types in API
- `example_interface-callback` - Non-exported callback implementations
- `example_splitpackage` - Basic split package problem
- `example_splitpackage_automatic-modules` - Split packages with automatic modules

**Workarounds & Advanced Techniques:**
- `example_addReads_addExports` - Command-line module boundary overrides
- `example_addExports_manifest` - Manifest-based exports
- `example_patch` - Patching modules at compile/runtime

**Migration & Integration:**
- `example_spring-hibernate` - Migrating Spring Boot application
- `example_compile-target-jdk8` - Multi-version compilation strategies
- `example_version` - Java 9+ version string handling (JEP 223)
- `example_agent` - Java agents in modular environment

## Repository Structure

The repository is organized as:
- Each `example_*` directory in `jigsaw-examples/` is a standalone, self-contained example
- One module typically equals one Eclipse project (but they cannot coexist in the same workspace due to overlapping names)
- Module source files are in `example_.../src` (this is the module-source-path)
- Compiled `.class` files go to `example_.../mods`
- JAR files go to `example_.../mlib` (the module-path at runtime)
- Third-party JARs (automatic modules) are in `example_.../amlib`
- Patch-related `.class` files are in `example_.../patches`, JARs in `example_.../patchlib`
- Old-style non-modular compilation results go to `example_.../classes`

## Build and Run Commands

### Environment Setup

Before running any examples, `jigsaw-examples/env.sh` must be configured with:
- `JAVA_HOME`: Path to JDK 9+ (tested with JDK 9, 10, 11)
- `JAVA8_HOME`: Only needed for `example_compile-target-jdk8`
- `MAVEN_HOME`: Path to Maven 3.5.2+ (3.6.1 for JDK 11)
- `GRADLE_HOME`: Path to Gradle 4.2.1+ (5.4.1 for JDK 11)
- `GRAPHVIZ_HOME`: Path to GraphViz 2.38 for module visualization
- `DEPVIS_HOME`: Path to depvis tool (https://github.com/accso/java9-jigsaw-depvis)
- `PATH_SEPARATOR`: Use `\;` on Windows (even in bash), `:` on Unix

### Top-level Commands (run from repository root)

All top-level scripts recursively execute the corresponding script in each example:

```bash
# Clean, compile, visualize, and run all examples
./jigsaw-examples/all.sh

# Clean all examples
./jigsaw-examples/allclean.sh

# Compile all examples
./jigsaw-examples/allcompile.sh

# Run all examples
./jigsaw-examples/allrun.sh

# Create GraphViz visualizations for all examples
./jigsaw-examples/allcreatevis.sh

# Print dependency info for all examples
./jigsaw-examples/alldepvis-print.sh
```

### Per-Example Commands

Each example directory contains these scripts:

```bash
cd jigsaw-examples/example_<name>/

# Do everything: clean, compile, run
./all.sh

# Clean generated files
./clean.sh

# Compile the example
./compile.sh

# Run the example
./run.sh

# Create GraphViz module dependency visualization
./depvis-vis.sh

# Print module dependency information
./depvis-print.sh
```

### Maven Examples

All Maven examples now include Maven Wrapper (3.9.11). Maven examples: `example_maven-project`, `example_maven-test-blackbox`, `example_maven-test-whitebox`, `example_spring-hibernate`.

```bash
# Build with Maven wrapper (recommended)
./mvnw clean package

# Or with system Maven (uses custom settings file where applicable)
mvn -s mvn_settings.xml clean package

# Run tests
./mvnw test

# Run the application (for projects with main class)
./mvnw exec:java
```

**Important**:
- Dependencies must be declared in both `module-info.java` AND `pom.xml`
- Maven compiler plugin version must be >= 3.6.1 (examples use 3.7.0)
- Maven wrapper (mvnw/mvnw.cmd) is included in all Maven examples

### Gradle Example

The `example_gradle-project` includes Gradle Wrapper (9.1.0):

```bash
# Build and run with wrapper (recommended)
./gradlew clean build

# Run tests
./gradlew test

# Run the application
./gradlew run
```

**Important**:
- Gradle 9.x requires Java 17 or later to run
- If using a newer JDK, set JAVA_HOME: `JAVA_HOME=<path-to-java-17> ./gradlew build`
- The build.gradle has been updated for Gradle 9.x compatibility:
  - Updated repository: `mavenCentral()` (replacing deprecated `jcenter()`)
  - Updated test API: `sourceSets.test.java.classesDirectory` (replacing deprecated `outputDir`)
  - Updated application plugin: `mainClass` property (replacing deprecated `mainClassName`)

## Module System Architecture

### Core Concepts

- **module-info.java**: Module descriptor defining dependencies (`requires`), exports (`exports`), services (`uses`/`provides`), and reflective access (`opens`)
- **Automatic modules**: JARs without `module-info.java` placed on module-path; module name derived from JAR filename or `Automatic-Module-Name` manifest entry
- **Unnamed module**: Code on the classpath (non-modular code)
- **Module layers**: Hierarchical organization of modules for isolation and versioning

### Common Module Patterns

**Basic requires/exports** (`example_requires_exports`):
```java
module modmain {
    requires modb;  // Read dependency on another module
}

module modb {
    exports pkgb;  // Make package accessible to other modules
}
```

**Transitive dependencies** (`example_requires_exports_requires-transitive_exports-to`):
```java
module modmain {
    requires transitive modb;  // Modules requiring modmain implicitly require modb
}
```

**Qualified exports** (`example_requires_exports-to`, `example_requires_exports_requires-transitive_exports-to`):
```java
module modb {
    exports pkgb to modmain;  // Only modmain can access pkgb
}
```

**Services** (`example_uses-provides`, `example_uses-provides_uses-in-client`):
```java
module modservice {
    exports com.service.api;
    uses com.service.api.Service;  // Consumer
}

module modservice.impl {
    requires modservice;
    provides com.service.api.Service with com.service.impl.ServiceImpl;  // Provider
}
```

**Reflective access** (`example_reflection`, `example_addReads_addExports_reflection`):
```java
open module modmain {  // Allow deep reflection to all packages
    requires modb;
}

// Or selectively:
module modmain {
    opens pkgmain to junit;  // Allow junit to reflectively access pkgmain
}
```

### Testing Approaches

**Blackbox testing** (`example_test`, `example_maven-test-blackbox`):
- Test module requires the module under test
- Only accesses exported API
- Example: `modtest.blackbox` requires `modfib`

**Whitebox testing** (`example_test`, `example_maven-test-whitebox`, `example_patch`):
- Uses `--patch-module` to inject test code into the module
- Allows testing internal (non-exported) packages
- Compile: `javac --patch-module modfib=patches/modfib ...`
- Run: `java --patch-module modfib=patchlib/modfib-test.jar ...`

### Module Resolution and Layers

**Boot layer** (`example_layer-modules-all-in-boot-layer`):
- Default layer containing JDK modules and application modules
- All modules resolved together

**Layer hierarchy** (`example_layer-hierarchy`, `example_layer-modules-grouped-in-hierarchy`):
- Parent-child layer relationships for isolation
- Child layers can see parent layer modules
- Useful for plugin architectures (see `example_jerrymouse` - module container/loader)

**Module resolution** (`example_resolved-modules`, `example_layer-modules-module-resolution`):
- Only modules transitively required from root modules are resolved
- Use `jlink` to create custom runtime images with resolved modules only

### Interop with Classpath/Unnamed Module

- **Explicit modules CANNOT require unnamed module** (`example_unnamed-module_access-from-explicit-module`)
- **Automatic modules CAN access unnamed module** (`example_unnamed-module_access-from-automatic-module`)
- **Unnamed module can access module-path** (`example_unnamed-module_accessing-module-path`)
- **Unnamed module reflection to JDK internals** (`example_unnamed-module-reflection-illegal-access`): Use `--illegal-access` flag (removed in newer JDKs)

### Command-line Overrides

When module system restrictions need to be bypassed at compile/runtime:

**--add-reads** (`example_addReads_addExports`):
```bash
javac --add-reads modmain=modb ...
java --add-reads modmain=modb ...
```

**--add-exports** (`example_addReads_addExports`, `example_addExports_manifest`):
```bash
javac --add-exports modb/pkgb.internal=modmain ...
java --add-exports modb/pkgb.internal=modmain ...
```

**--patch-module** (`example_patch`):
```bash
javac --patch-module modfib=patches/modfib ...
java --patch-module modfib=patchlib/modfib-test.jar ...
```

## Common Pitfalls

### Split Packages
(`example_splitpackage`, `example_splitpackage_automatic-modules`)

**Problem**: Same package in multiple modules causes compilation/runtime errors.
- Particularly problematic with automatic modules, which automatically read all other automatic modules on module-path
- **Solution**: Rename packages or merge modules

### Accessibility Issues
(`example_derived_private-package-protected`, `example_exceptions`, `example_interface-callback`)

**Problem**: Even if a type is exported, its superclass/exception/callback implementation may not be accessible if their packages aren't exported.
- **Solution**: Export all packages containing types in public API signatures, or use qualified exports

### Resource Access
(`example_resources`)

Resources in modules are only accessible:
- From within the module
- Via `Module.getResourceAsStream()` if module is open or opens the package

## Module Naming Conventions
(`example_naming-modules`)

- Use reverse DNS notation: `com.company.module`
- Cannot start with `java.` or `jdk.` (reserved for JDK modules)
- Hyphens in names require special handling (use underscores in module-info)

## Notes

- All scripts are bash scripts - use bash on Windows (Babun, git bash, WSL)
- Eclipse support: Projects included but must be in separate workspaces due to name conflicts
- `example_spring-hibernate` may have issues with certain JDK versions (check its readme.md)
- Module names often use legacy naming (`modb`, `modc`) from earlier refactorings - this is intentional
- The `modmain` module in most examples is declared as `open module` to support usage in `example_jerrymouse`
