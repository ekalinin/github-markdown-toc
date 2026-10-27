# Spec Delta

## Purpose

Keeps the TOC a markdown list when the document has no `#` heading, by indenting the
entries relative to the top heading level of the document instead of `#`.

## ADDED Requirements

### Requirement: Indent relative to the top level

Every TOC entry SHALL be indented by `(level - top) * indent` spaces, where `level` is
the heading level of the entry (`#` is level 1, `######` is level 6), `top` is the
smallest heading level among the TOC entries of the same document, and `indent` is the
value of `--indent <NUM>` (3 by default). Entries at the `top` level SHALL have no
indent. This SHALL apply to every input: stdin, a local file, a remote URL, several
inputs, and `--insert`. With several inputs, each document SHALL have its own `top`.

#### Scenario: Document with a `#` heading

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_depth.md"`
- **THEN** the TOC entries are `* [Title one](#title-one)`, `   * [Section](#section)`,
  `      * [Subsection](#subsection)`, `         * [Deep](#deep)`,
  `* [Title two](#title-two)`

#### Scenario: Local file without a `#` heading

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_noh1.md"`, where the file
  has the headings `## Section one`, `### Subsection`, `## Section two`
- **THEN** the TOC entries are `* [Section one](#section-one)`,
  `   * [Subsection](#subsection)`, `* [Section two](#section-two)`, followed by
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`

#### Scenario: Stdin with an indent of 4

- **WHEN** the user runs
  `cat "tests/test directory/test_noh1.md" | gh-md-toc --indent 4 -`
- **THEN** the output is `* [Section one](#section-one)`,
  `    * [Subsection](#subsection)`, `* [Section two](#section-two)`

#### Scenario: Several inputs

- **WHEN** the user runs
  `gh-md-toc "tests/test directory/test_plussign.md" "tests/test directory/test_noh1.md"`
- **THEN** the entries of `test_noh1.md` are
  `* [Section one](tests/test directory/test_noh1.md#section-one)`,
  `   * [Subsection](tests/test directory/test_noh1.md#subsection)`,
  `* [Section two](tests/test directory/test_noh1.md#section-two)`
