# Spec Delta

## MODIFIED Requirements

### Requirement: Hierarchical numbers

With `--numbered outline`, every TOC entry SHALL have the form
`<bullet> [<number> <heading text>](<link>)`, where `<bullet>` is the value of
`--bullet <CHAR>` (`*` by default), indented by `(level - top) * indent` spaces, where
`top` is the smallest heading level among the entries of the document. The heading text
and the link SHALL be the same as without `--numbered`.

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
