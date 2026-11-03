# Spec Delta

## MODIFIED Requirements

### Requirement: Link prefix with several inputs

When more than one input is given, every TOC entry SHALL have the form
`* [<heading text>](<input>#<anchor>)`, where `<input>` is the input as given on the
command line with every space replaced by `%20`. No other character of the input SHALL be
changed, and entries of an input without a space SHALL NOT change. This SHALL apply to the
output without `--insert` and to the entries of a remote URL with `--insert`. A local file
with `--insert` SHALL follow the requirement Insert into several files. Everything else
that shows an input, such as the skipped level warning on stderr, SHALL show it as given,
with spaces.

#### Scenario: Two local files in a directory with a space

- **WHEN** the user runs
  `gh-md-toc "tests/test directory/test_depth.md" "tests/test directory/test_numbered.md"`
- **THEN** the entries of the first file are
  `* [Title one](tests/test%20directory/test_depth.md#title-one)`,
  `   * [Section](tests/test%20directory/test_depth.md#section)`,
  `      * [Subsection](tests/test%20directory/test_depth.md#subsection)`,
  `         * [Deep](tests/test%20directory/test_depth.md#deep)`,
  `* [Title two](tests/test%20directory/test_depth.md#title-two)`, and the first entry of
  the second file is `* [Title one](tests/test%20directory/test_numbered.md#title-one)`

#### Scenario: Warning keeps the input as given

- **WHEN** the user runs
  `gh-md-toc "tests/test directory/test_depth.md" "tests/test directory/test_numbered.md"`
- **THEN** stderr is
  `tests/test directory/test_numbered.md: Warning: heading 'Skipped' (level 3) skips a level after 'Title two' (level 1), see https://github.com/ekalinin/github-markdown-toc/issues/75`

#### Scenario: Input without a space

- **WHEN** the user runs `gh-md-toc README.md https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md`
- **THEN** the first entry is `* [gh-md-toc](README.md#gh-md-toc)` and the first entry of
  the remote file is
  `* [sitemap.js](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#sitemapjs)`

## ADDED Requirements

### Requirement: Insert into several files

With `--insert` and more than one input, every TOC entry of a local file SHALL link to
`#<anchor>` only, without the input, as with one input. This SHALL apply to the TOC
written into the file and to the TOC printed on stdout for that file. The skipped level
warning SHALL still start with the input as given on the command line, followed by `: `.
The entries of a remote URL SHALL keep the prefix: nothing is inserted for them.

#### Scenario: Two local files and a remote URL

- **WHEN** the user runs
  `gh-md-toc --insert --no-backup --hide-footer <dir>/a.md <dir>/b.md https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md`,
  where `a.md` has the lines `<!--ts-->`, `<!--te-->` and the headings `# Page a`,
  `## Usage`, and `b.md` has the lines `<!--ts-->`, `<!--te-->` and the headings
  `# Title`, `### Skipped`
- **THEN** the lines between `<!--ts-->` and `<!--te-->` in `a.md` are
  `* [Page a](#page-a)` and `   * [Usage](#usage)`, in `b.md` they are
  `* [Title](#title)` and `      * [Skipped](#skipped)`, stdout has the same entries and
  `* [sitemap.js](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#sitemapjs)`,
  stderr is
  `<dir>/b.md: Warning: heading 'Skipped' (level 3) skips a level after 'Title' (level 1), see https://github.com/ekalinin/github-markdown-toc/issues/75`,
  and the exit code is 0
