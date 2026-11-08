# Spec Delta

## MODIFIED Requirements

### Requirement: Plain text of the heading

The text of every TOC entry SHALL be the heading text as GitHub renders it, with all
HTML tags removed. The text inside link, image, formatting and inline HTML elements
(such as `<a>`, `<em>`, `<strong>`, `<sub>`) SHALL be kept. HTML entities SHALL stay as
GitHub renders them (`&amp;`, `&lt;`), and the spaces around a removed element SHALL
stay as they are. Entries of headings without HTML tags SHALL NOT change. This SHALL
apply to every input: stdin, a local file, a remote URL, several inputs, `--insert` and
`--stdout`. With `--keep-code`, the inline code of the heading SHALL be written as in
`toc-keep-code`, and the rest of the text SHALL follow this requirement.

#### Scenario: Escaped characters are not tags

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_headingmarkup.md"`
- **THEN** the entry of the heading `## Tom & Jerry <3` is
  `   * [Tom &amp; Jerry &lt;3](#tom--jerry-3)`

#### Scenario: Formatted setext heading with --insert

- **WHEN** the user runs
  `gh-md-toc --no-backup --hide-footer "tests/test directory/test_setextwithformatting.md"`,
  where the file has the setext heading `` *Title `two`* `` underlined with `=`
- **THEN** the entry of that heading is `* [Title two](#title-two)`, in the output and
  in the TOC between `<!--ts-->` and `<!--te-->` in the file
