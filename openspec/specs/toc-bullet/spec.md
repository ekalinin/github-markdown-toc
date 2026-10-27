# toc-bullet Specification

## Purpose

Lets the user start the bullet entries of the TOC with `-` or `+` instead of `*`, for any
input.

## Requirements

### Requirement: Bullet character

With `--bullet <CHAR>`, where `CHAR` is `*`, `-` or `+`, every TOC entry SHALL have the
form `<CHAR> [<heading text>](<link>)`. The indentation, the heading text and the link
SHALL be the same as without `--bullet`.

#### Scenario: Local file

- **WHEN** the user runs `gh-md-toc --bullet - "tests/test directory/test_depth.md"`,
  where the file has the headings `# Title one`, `## Section`, `### Subsection`,
  `#### Deep`, `# Title two`
- **THEN** the TOC entries are `- [Title one](#title-one)`, `   - [Section](#section)`,
  `      - [Subsection](#subsection)`, `         - [Deep](#deep)`,
  `- [Title two](#title-two)`, followed by
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`

### Requirement: Every input

`--bullet` SHALL apply to every input: stdin, a local file, a remote URL, several inputs,
and `--insert`. With `--numbered outline`, every entry SHALL start with `CHAR` instead of
`*`.

`--bullet <CHAR>` SHALL be accepted after `--indent <NUM>`, `--depth <NUM>` and
`--numbered <TYPE>` (when given) and before `-`, `--insert`, `--no-backup`,
`--hide-footer`, `--skip-header` and the inputs. A `-` right after `--bullet` SHALL be
taken as `CHAR`, not as stdin.

#### Scenario: Stdin with a dash

- **WHEN** the user runs
  `cat "tests/test directory/test_depth.md" | gh-md-toc --bullet - -`
- **THEN** the output is `- [Title one](#title-one)`, `   - [Section](#section)`,
  `      - [Subsection](#subsection)`, `         - [Deep](#deep)`,
  `- [Title two](#title-two)`

#### Scenario: Outline numbers

- **WHEN** the user runs
  `gh-md-toc --numbered outline --bullet + "tests/test directory/test_numbered.md"`,
  where the file has the headings `# Title one`, `## Section`, `### Subsection`,
  `## Other section`, `# Title two`, `### Skipped`, `## After skip`
- **THEN** the TOC entries are `+ [1. Title one](#title-one)`,
  `   + [1.1. Section](#section)`, `      + [1.1.1. Subsection](#subsection)`,
  `   + [1.2. Other section](#other-section)`, `+ [2. Title two](#title-two)`,
  `      + [2.1. Skipped](#skipped)`, `   + [2.2. After skip](#after-skip)`

### Requirement: Asterisk by default

Without `--bullet`, every bullet entry of the TOC SHALL start with `*`, as before this
change.

#### Scenario: Without the option

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_depth.md"`
- **THEN** the TOC entries are `* [Title one](#title-one)`, `   * [Section](#section)`,
  `      * [Subsection](#subsection)`, `         * [Deep](#deep)`,
  `* [Title two](#title-two)`

### Requirement: Invalid usage

With a `CHAR` other than `*`, `-` or `+`, the program SHALL print
`Unknown bullet for --bullet: '<CHAR>'. Use '*', '-' or '+'.` and exit with code 1
without printing a TOC.

With `--bullet` and `--numbered list`, the program SHALL print
`--bullet cannot be used with --numbered list.` and exit with code 1 without printing a
TOC.

#### Scenario: Unknown character

- **WHEN** the user runs `gh-md-toc --bullet x README.md`
- **THEN** the output is `Unknown bullet for --bullet: 'x'. Use '*', '-' or '+'.` and
  the exit code is 1

#### Scenario: Ordered list

- **WHEN** the user runs `gh-md-toc --numbered list --bullet - README.md`
- **THEN** the output is `--bullet cannot be used with --numbered list.` and the exit
  code is 1

### Requirement: Help lists the option

`--help` SHALL list `--bullet <CHAR>` in the "Options" section right after
`--numbered <TYPE>`.

#### Scenario: Help output

- **WHEN** the user runs `gh-md-toc --help`
- **THEN** the line after
  `  --numbered <TYPE>   Number TOC entries: list (ordered list) or outline (1.1. in text). Default: none.`
  is `  --bullet <CHAR>     Bullet of TOC entries: *, - or +. Default: *.`
