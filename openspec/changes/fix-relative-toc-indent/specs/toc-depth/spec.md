# Spec Delta

## MODIFIED Requirements

### Requirement: TOC limited by heading level

With `--depth <NUM>` where `NUM` is greater than 0, the TOC SHALL contain entries only for
headings whose level is less than or equal to `NUM` (`#` is level 1, `######` is level
6). The level is absolute: it does not depend on the highest level present in the
document. The remaining entries SHALL be the same as without `--depth`: same text, same
anchor, same order, same indentation of `(level - top) * indent` spaces, where `top` is
the smallest heading level among the entries of the document. This SHALL apply to every
input: stdin, a local file, a remote URL, several inputs, and `--insert`.

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

#### Scenario: Document without a `#` heading

- **WHEN** the user runs
  `cat "tests/test directory/test_noh1.md" | gh-md-toc --depth 2 -`, where the file has
  the headings `## Section one`, `### Subsection`, `## Section two`
- **THEN** the output is `* [Section one](#section-one)` and
  `* [Section two](#section-two)`
