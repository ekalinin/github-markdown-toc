# Spec Delta

## Purpose

Keeps every TOC entry a working link when more than one input is given, also when the
path of an input has spaces, as the names of GitHub wiki pages can.

## ADDED Requirements

### Requirement: Link prefix with several inputs

When more than one input is given, every TOC entry SHALL have the form
`* [<heading text>](<input>#<anchor>)`, where `<input>` is the input as given on the
command line with every space replaced by `%20`. No other character of the input SHALL be
changed, and entries of an input without a space SHALL NOT change. This SHALL apply to the
output and to the TOC that `--insert` writes. Everything else that shows an input, such as
the skipped level warning on stderr, SHALL show it as given, with spaces.

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

### Requirement: One input with a space in the path

With one input, every TOC entry SHALL link to `#<anchor>` only, without the input, also
when the path of the input has a space.

#### Scenario: Local file in a directory with a space

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_filepathwithspace.md"`
- **THEN** the TOC entries are `* [Title](#title)` and
  `   * [This is test for file path with space](#this-is-test-for-file-path-with-space)`
