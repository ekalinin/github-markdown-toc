# Spec Delta

## Purpose

Lets the user get a numbered TOC instead of a bullet list: either a markdown ordered list
or entries with hierarchical numbers like `2.1.`, for any input.

## ADDED Requirements

### Requirement: Ordered list

With `--numbered list`, every TOC entry SHALL have the form `1. [<heading text>](<link>)`,
with the marker `1.` for every entry, indented by `(level - 1) * indent` spaces. The
heading text and the link SHALL be the same as without `--numbered`.

#### Scenario: Local file

- **WHEN** the user runs `gh-md-toc --numbered list "tests/test directory/test_numbered.md"`,
  where the file has the headings `# Title one`, `## Section`, `### Subsection`,
  `## Other section`, `# Title two`, `### Skipped`, `## After skip`
- **THEN** the TOC entries are `1. [Title one](#title-one)`, `   1. [Section](#section)`,
  `      1. [Subsection](#subsection)`, `   1. [Other section](#other-section)`,
  `1. [Title two](#title-two)`, `      1. [Skipped](#skipped)`,
  `   1. [After skip](#after-skip)`, followed by
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`

### Requirement: Hierarchical numbers

With `--numbered outline`, every TOC entry SHALL have the form
`* [<number> <heading text>](<link>)`, indented by `(level - 1) * indent` spaces. The
heading text and the link SHALL be the same as without `--numbered`.

The number SHALL follow the heading tree of the entries in the TOC. The parent of an
entry is the nearest previous entry with a lower heading level; entries without a parent
are top entries. The number of a top entry SHALL be its position among the top entries
followed by a dot (`1.`, `2.`). The number of any other entry SHALL be the number of its
parent followed by its position among the children of that parent and a dot (`2.1.`,
`2.1.3.`). A skipped heading level SHALL NOT add a part to the number.

#### Scenario: Local file

- **WHEN** the user runs
  `gh-md-toc --numbered outline "tests/test directory/test_numbered.md"`
- **THEN** the TOC entries are `* [1. Title one](#title-one)`,
  `   * [1.1. Section](#section)`, `      * [1.1.1. Subsection](#subsection)`,
  `   * [1.2. Other section](#other-section)`, `* [2. Title two](#title-two)`,
  `      * [2.1. Skipped](#skipped)`, `   * [2.2. After skip](#after-skip)`

### Requirement: Every input

`--numbered` SHALL apply to every input: stdin, a local file, a remote URL, several
inputs, and `--insert`. With several inputs, the numbers of each document SHALL start
from `1.`. With `--depth`, the TOC SHALL number only the entries that `--depth` keeps.

`--numbered <TYPE>` SHALL be accepted after `--indent <NUM>` and `--depth <NUM>` (when
given) and before `-`, `--insert`, `--no-backup`, `--hide-footer`, `--skip-header` and
the inputs.

#### Scenario: Stdin with depth

- **WHEN** the user runs
  `cat "tests/test directory/test_numbered.md" | gh-md-toc --depth 2 --numbered outline -`
- **THEN** the output is `* [1. Title one](#title-one)`, `   * [1.1. Section](#section)`,
  `   * [1.2. Other section](#other-section)`, `* [2. Title two](#title-two)`,
  `   * [2.1. After skip](#after-skip)`

### Requirement: Bullets by default

Without `--numbered`, every TOC entry SHALL have the form `* [<heading text>](<link>)`,
as before this change.

#### Scenario: Without the option

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_numbered.md"`
- **THEN** the TOC entries are `* [Title one](#title-one)`, `   * [Section](#section)`,
  `      * [Subsection](#subsection)`, `   * [Other section](#other-section)`,
  `* [Title two](#title-two)`, `      * [Skipped](#skipped)`,
  `   * [After skip](#after-skip)`

### Requirement: Invalid usage

With a type other than `list` or `outline`, the program SHALL print
`Unknown type for --numbered: '<TYPE>'. Use 'list' or 'outline'.` and exit with code 1
without printing a TOC.

With `--numbered list` and an indent less than 3, the program SHALL print
`--numbered list requires --indent 3 or more, got '<NUM>'.` and exit with code 1
without printing a TOC.

#### Scenario: Unknown type

- **WHEN** the user runs `gh-md-toc --numbered roman README.md`
- **THEN** the output is
  `Unknown type for --numbered: 'roman'. Use 'list' or 'outline'.` and the exit code
  is 1

#### Scenario: Indent too small for a list

- **WHEN** the user runs `gh-md-toc --indent 2 --numbered list README.md`
- **THEN** the output is `--numbered list requires --indent 3 or more, got '2'.` and the
  exit code is 1

#### Scenario: Small indent with outline

- **WHEN** the user runs
  `gh-md-toc --indent 2 --numbered outline "tests/test directory/test_numbered.md"`
- **THEN** the program prints the TOC and exits with code 0

### Requirement: Help lists the option

`--help` SHALL list `--numbered <TYPE>` in the "Options" section right after
`--depth <NUM>`.

#### Scenario: Help output

- **WHEN** the user runs `gh-md-toc --help`
- **THEN** the line after
  `  --depth <NUM>       Max heading level to include into TOC. Default: 0 (all levels).`
  is
  `  --numbered <TYPE>   Number TOC entries: list (ordered list) or outline (1.1. in text). Default: none.`
