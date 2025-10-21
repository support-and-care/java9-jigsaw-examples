# Markdown to AsciiDoc Transformation Guide

This guide documents patterns and best practices for converting Markdown (`.md`) files to AsciiDoc (`.adoc` or `.ad`) format.

## Transformation Objectives

- Convert Markdown documentation to AsciiDoc format
- Preserve git history using `git mv`
- Improve semantic meaning using AsciiDoc admonition blocks
- Maintain readability and structure

## Process

1. **Preserve History**: Always use `git mv README.md README.adoc` to preserve git history
2. **Fix Encoding**: Convert from ISO-8859-1 (or similar) to UTF-8 to handle special characters (e.g., "Rüdiger")
3. **Convert Content**: Apply systematic conversions following the patterns below
4. **Verify**: Check that tables, code blocks, and admonitions render correctly

## Conversion Patterns

### Headers

| Markdown | AsciiDoc | Notes |
|----------|----------|-------|
| `# Title` | `= Title` | Document title (only one per document) |
| `## Section` | `== Section` | Level 2 heading |
| `### Subsection` | `=== Subsection` | Level 3 heading |
| `#### Sub-subsection` | `==== Sub-subsection` | Level 4 heading |

**Rule**: Number of `=` signs equals heading level in AsciiDoc.

### Text Formatting

| Markdown | AsciiDoc | Notes |
|----------|----------|-------|
| `**bold**` | `*bold*` | Single asterisks for bold |
| `*italic*` | `_italic_` | Underscores for italic |
| `` `code` `` | `` `code` `` | Same as Markdown |
| `_italic_` (rare) | `_italic_` | Works but prefer for italic consistently |

### Lists

#### Numbered Lists

| Markdown | AsciiDoc |
|----------|----------|
| `1. First item` | `. First item` |
| `2. Second item` | `. Second item` |

**Rule**: Use `.` prefix for auto-numbering (no explicit numbers).

#### Unordered Lists

| Markdown | AsciiDoc | Notes |
|----------|----------|-------|
| `- Item` | `* Item` | Level 1 |
| `  - Nested` | `** Nested` | Level 2 |
| `    - Double nested` | `*** Double nested` | Level 3 |

**Rule**: Use `*`, `**`, `***` for nesting levels. Never use `-` in AsciiDoc lists.

#### Task Lists (Checkboxes)

| Markdown | AsciiDoc |
|----------|----------|
| `- [ ] Task` | `* [ ] Task` |
| `- [x] Done` | `* [x] Done` |

**Rule**: Same syntax but use `*` instead of `-`.

### Links

| Markdown | AsciiDoc | When to Use |
|----------|----------|-------------|
| `[text](https://example.com)` | `https://example.com[text]` | Always preferred |
| `https://example.com` | `https://example.com` | Bare URLs work in both |
| N/A | `link:https://example.com[text]` | Only for URLs with special characters |

**Important Rule**: Do NOT use `link:` prefix for simple http/https URLs. AsciiDoc automatically converts them to links.

**Examples**:
- ✅ Good: `https://github.com/user[GitHub Profile]`
- ❌ Bad: `link:https://github.com/user[GitHub Profile]`
- ✅ Exception: `link:file:///path/to/file[local file]` (special protocol)

### Images

| Markdown | AsciiDoc |
|----------|----------|
| `![alt text](image.png)` | `image::image.png[alt text]` |
| `![alt text](path/to/image.png)` | `image::path/to/image.png[alt text]` |

**Rule**: Use `image::filename[alt text]` syntax. Note the double colon `::` for block images.

**Examples**:
- Markdown: `![Module Dependency Graph](moduledependencies.png)`
- AsciiDoc: `image::moduledependencies.png[Module Dependency Graph]`

### Code Blocks

**Markdown**:
````markdown
```bash
command here
```
````

**AsciiDoc**:
````
[source,bash]
----
command here
----
````

**Rule**: Use `[source,language]` with `----` delimiters (4 dashes).

### Blockquotes and Admonitions

Markdown blockquotes should be converted to semantic AsciiDoc admonition blocks:

| Markdown | AsciiDoc | Use Case |
|----------|----------|----------|
| `> Note: ...` | `[NOTE]\n====\n...\n====` | General notes |
| `> Tip: ...` | `[TIP]\n====\n...\n====` | Helpful tips |
| `> Warning: ...` | `[WARNING]\n====\n...\n====` | Warnings |
| `> Important: ...` | `[IMPORTANT]\n====\n...\n====` | Critical information |
| `> [!NOTE]\n> text` | `[NOTE]\n====\ntext\n====` | GitHub-style alert (NOTE) |
| `> [!TIP]\n> text` | `[TIP]\n====\ntext\n====` | GitHub-style alert (TIP) |
| `> [!WARNING]\n> text` | `[WARNING]\n====\ntext\n====` | GitHub-style alert (WARNING) |
| `> [!IMPORTANT]\n> text` | `[IMPORTANT]\n====\ntext\n====` | GitHub-style alert (IMPORTANT) |

**Rule**: GitHub-style alerts (`> [!NOTE]`) should be converted to corresponding AsciiDoc admonitions, removing the `> ` prefix from continuation lines.

**Example**:

Markdown:
```markdown
> **Tip**: Use a local Maven repository to avoid polluting your global one.
```

AsciiDoc:
```
[TIP]
====
Use a local Maven repository to avoid polluting your global one.
====
```

### Tables

#### Simple Tables (3-4 columns)

**Markdown**:
```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
```

**AsciiDoc**:
```
[cols="1,1,1",options="header"]
|===
| Column 1 | Column 2 | Column 3

| Data 1 | Data 2 | Data 3
|===
```

**Rules**:
- Define column widths in `[cols="..."]` (proportional widths)
- Use `options="header"` for header row
- Blank line after header row
- Use `|===` to delimit table

#### Tables with Category Headers (Multi-column Spanning)

When converting tables with category rows that span multiple columns:

**Markdown** (with empty first column):
```markdown
|     | Col1 | Col2 | Col3 |
|-----|------|------|------|
| **Category 1** ||||
|     | data | data | data |
```

**AsciiDoc**:
```
[cols="2,5,2",options="header"]
|===
| Col1 | Col2 | Col3

3+| *Category 1*
| data | data | data
|===
```

**Rules**:
- Remove empty first column
- Use `N+|` syntax for spanning N columns (e.g., `3+|` spans 3 columns)
- Adjust column count in `[cols="..."]` accordingly

### HTML Elements

Convert HTML to semantic AsciiDoc where possible:

| HTML | AsciiDoc Alternative |
|------|---------------------|
| `<span style="color:red">Warning...</span>` | `[WARNING]\n====\nWarning...\n====` |
| `<s>deprecated</s>` | `+++<s>+++deprecated+++</s>+++` |
| `<br>` | Blank line or `+` for line continuation |

**Rule**: Prefer semantic admonitions over styled HTML. Use passthrough `+++` only when necessary.

### Line Breaks

**Markdown**: Sentences can flow continuously.

**AsciiDoc Best Practice**: One sentence per line.

**Example**:
```
This is sentence one.
This is sentence two.
This makes diffs cleaner.
```

## Common Issues and Solutions

### Issue 1: Duplicate Lines
- **Problem**: Original file had duplicate "Build Tool Wrappers" line
- **Solution**: Remove duplicates during conversion

### Issue 2: Incomplete Sentences
- **Problem**: Sentence ending with "e.g., by" (incomplete)
- **Solution**: Complete the sentence or remove dangling text

### Issue 3: Empty Table Columns
- **Problem**: Markdown tables with empty first column for formatting
- **Solution**: Remove the column entirely, adjust column counts and spanning

## Checklist for Conversion

- [ ] Use `git mv` to preserve history
- [ ] Convert headers (`#` → `=`)
- [ ] Convert lists (`-` → `*`, numbered to `.`)
- [ ] Convert code blocks to `[source,lang]` with `----`
- [ ] Convert blockquotes to admonition blocks where appropriate
- [ ] Remove `link:` prefix from simple URLs
- [ ] Fix table structure (remove empty columns, use spanning)
- [ ] Convert HTML to semantic AsciiDoc
- [ ] Apply one sentence per line formatting
- [ ] Fix any issues found (duplicates, incomplete text)
- [ ] Verify rendering

## Testing

After conversion, verify:
1. Headers render at correct levels
2. Links are clickable
3. Code blocks have syntax highlighting
4. Tables display correctly
5. Admonition blocks render with proper styling
6. Lists have correct nesting

## Reference

- AsciiDoc syntax: https://docs.asciidoctor.org/asciidoc/latest/syntax-quick-reference/
- Global AsciiDoc conventions: `~/.claude/CLAUDE.md`
- Project documentation conventions: `CLAUDE.md`
