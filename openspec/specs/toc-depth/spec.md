# toc-depth Specification

## Purpose

Lets the user limit the generated TOC to headings up to a given level, e.g. only `#` and
`##`, for any input.

## Requirements

### Requirement: TOC limited by heading level

With `--depth <NUM>` where `NUM` is greater than 0, the TOC SHALL contain entries only for
headings whose level is less than or equal to `NUM` (`#` is level 1, `######` is level
6). The level is absolute: it does not depend on the highest level present in the
document. The remaining entries SHALL be the same as without `--depth`: same text, same
anchor, same order, same indentation of `(level - 1) * indent` spaces. This SHALL apply
to every input: stdin, a local file, a remote URL, several inputs, and `--insert`.

`--depth <NUM>` SHALL be accepted after `--indent <NUM>` (when given) and before `-`,
`--insert`, `--no-backup`, `--hide-footer`, `--skip-header` and the inputs.

#### Scenario: Local file

- **WHEN** the user runs `gh-md-toc --depth 2 "tests/test directory/test_depth.md"`,
  where the file has the headings `# Title one`, `## Section`, `### Subsection`,
  `#### Deep`, `# Title two`
- **THEN** the TOC entries are `* [Title one](#title-one)`, `   * [Section](#section)`,
  `* [Title two](#title-two)`, followed by
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`

#### Scenario: Stdin

- **WHEN** the user runs
  `cat "tests/test directory/test_depth.md" | gh-md-toc --depth 1 -`
- **THEN** the output is `* [Title one](#title-one)` and `* [Title two](#title-two)`

### Requirement: No limit by default

Without `--depth`, or with `--depth 0`, the TOC SHALL contain an entry for every heading
of the document, as before this change.

#### Scenario: Without the option

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_depth.md"`
- **THEN** the TOC entries are `* [Title one](#title-one)`, `   * [Section](#section)`,
  `      * [Subsection](#subsection)`, `         * [Deep](#deep)`,
  `* [Title two](#title-two)`

#### Scenario: Zero depth

- **WHEN** the user runs `gh-md-toc --depth 0 "tests/test directory/test_depth.md"`
- **THEN** the TOC entries are the same as without the option

### Requirement: Help lists the option

`--help` SHALL list `--depth <NUM>` in the "Options" section right after
`--indent <NUM>`.

#### Scenario: Help output

- **WHEN** the user runs `gh-md-toc --help`
- **THEN** the line after `  --indent <NUM>      Set indent size. Default: 3.` is
  `  --depth <NUM>       Max heading level to include into TOC. Default: 0 (all levels).`
