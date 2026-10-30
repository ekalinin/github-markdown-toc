# toc-skipped-level Specification

## Purpose

Tells the user which headings skip a heading level, because GitHub can render the TOC
entry of such a heading as text of its parent entry, while the TOC itself stays the same.

## Requirements

### Requirement: Warning for a skipped level

For every TOC entry whose heading level is greater than the level of its parent plus 1,
the program SHALL print to stderr the line
`Warning: heading '<text>' (level <level>) skips a level after '<parent text>' (level <parent level>), see https://github.com/ekalinin/github-markdown-toc/issues/75`.
The parent of an entry is the nearest previous TOC entry with a lower heading level, as
for `--numbered outline`. `<text>` and `<parent text>` are the heading texts as in the TOC
entries, without the `--numbered outline` number. `#` is level 1, `######` is level 6.

There SHALL be one line per such entry, in document order. An entry without a parent, or
with a level equal to the level of its parent plus 1, SHALL NOT get a warning.

#### Scenario: Local file

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_numbered.md"`, where the
  file has the headings `# Title one`, `## Section`, `### Subsection`,
  `## Other section`, `# Title two`, `### Skipped`, `## After skip`
- **THEN** stderr is
  `Warning: heading 'Skipped' (level 3) skips a level after 'Title two' (level 1), see https://github.com/ekalinin/github-markdown-toc/issues/75`
  and the exit code is 0

#### Scenario: Entries without a parent and two skipped levels

- **WHEN** the user runs
  `printf '### First\n\n## Second\n\n#### Third\n\n### Fourth\n\n###### Fifth\n' | gh-md-toc -`
- **THEN** stderr is the two lines
  `Warning: heading 'Third' (level 4) skips a level after 'Second' (level 2), see https://github.com/ekalinin/github-markdown-toc/issues/75`
  and
  `Warning: heading 'Fifth' (level 6) skips a level after 'Fourth' (level 3), see https://github.com/ekalinin/github-markdown-toc/issues/75`,
  and the exit code is 0

### Requirement: TOC does not change

The TOC SHALL be the same as without the warning: on stdout, in the file with
`--insert`, and in the output of `--stdout`. The warning SHALL NOT be printed to stdout
and SHALL NOT be written into the file. The exit code SHALL be the same as without the
warning.

#### Scenario: Local file

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_numbered.md"`
- **THEN** the TOC entries on stdout are `* [Title one](#title-one)`,
  `   * [Section](#section)`, `      * [Subsection](#subsection)`,
  `   * [Other section](#other-section)`, `* [Title two](#title-two)`,
  `      * [Skipped](#skipped)`, `   * [After skip](#after-skip)`, followed by
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`

#### Scenario: Insert into a file

- **WHEN** the user runs `gh-md-toc --insert --no-backup --hide-footer <file>`, where the
  file has the lines `<!--ts-->`, `<!--te-->` and the headings `# Title`, `### Skipped`
- **THEN** the lines between `<!--ts-->` and `<!--te-->` in the file are
  `* [Title](#title)` and `      * [Skipped](#skipped)`, stderr is
  `Warning: heading 'Skipped' (level 3) skips a level after 'Title' (level 1), see https://github.com/ekalinin/github-markdown-toc/issues/75`,
  and the exit code is 0

#### Scenario: Whole file to stdout

- **WHEN** the user runs
  `printf '<!--ts-->\n<!--te-->\n\n# Title\n\n### Skipped\n' | gh-md-toc --hide-footer --stdout -`
- **THEN** stdout is the lines `<!--ts-->`, `* [Title](#title)`,
  `      * [Skipped](#skipped)`, `<!--te-->`, an empty line, `# Title`, an empty line,
  `### Skipped`, stderr is
  `Warning: heading 'Skipped' (level 3) skips a level after 'Title' (level 1), see https://github.com/ekalinin/github-markdown-toc/issues/75`,
  and the exit code is 0

### Requirement: Every input

The warning SHALL apply to every input: stdin, a local file, a remote URL, several
inputs, `--insert` and `--stdout`. With several inputs, each document SHALL be checked on
its own, and each line SHALL start with the input as given on the command line, followed
by `: `. With `--depth`, only the entries that `--depth` keeps SHALL be checked, and the
parent SHALL be taken among them.

#### Scenario: Several inputs

- **WHEN** the user runs
  `gh-md-toc "tests/test directory/test_depth.md" "tests/test directory/test_numbered.md"`
- **THEN** stderr is
  `tests/test directory/test_numbered.md: Warning: heading 'Skipped' (level 3) skips a level after 'Title two' (level 1), see https://github.com/ekalinin/github-markdown-toc/issues/75`

#### Scenario: Stdin with depth

- **WHEN** the user runs
  `cat "tests/test directory/test_numbered.md" | gh-md-toc --depth 2 -`
- **THEN** stderr is empty, because `--depth 2` drops `### Skipped`

### Requirement: No warning without skipped levels

For a document where no TOC entry skips a level, the program SHALL NOT print a warning.

#### Scenario: Consecutive levels

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_depth.md"`, where the file
  has the headings `# Title one`, `## Section`, `### Subsection`, `#### Deep`,
  `# Title two`
- **THEN** stderr is empty and the exit code is 0
