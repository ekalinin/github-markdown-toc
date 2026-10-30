# toc-heading-markup Specification

## Purpose
Keeps every TOC entry pointing to its own heading and readable as plain text when the
heading contains links, images, formatting or inline HTML.

## Requirements

### Requirement: Link to the heading's own anchor

The link of every TOC entry SHALL be the anchor that GitHub renders for the heading
itself, also when the heading text contains links or images. A link or an image inside
the heading text SHALL NOT be used as the link of the entry. This SHALL apply to every
input: stdin, a local file, a remote URL, several inputs, `--insert` and `--stdout`.

#### Scenario: Headings with links, an image, formatting and escaped characters

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_headingmarkup.md"`, where
  the file has the headings `# Top`, `## On <sub><sub>[Go to Top](#top)</sub></sub>`,
  `## [My issue](https://github.com/ekalinin/github-markdown-toc/issues/67)`,
  `## See [docs](#top) here`, `## Linux vs. Samba ***permissions***`,
  `## A ![img](x.png) B`, `## Tom & Jerry <3`
- **THEN** the TOC entries are `* [Top](#top)`, `   * [On Go to Top](#on-go-to-top)`,
  `   * [My issue](#my-issue)`, `   * [See docs here](#see-docs-here)`,
  `   * [Linux vs. Samba permissions](#linux-vs-samba-permissions)`,
  `   * [A  B](#a--b)`, `   * [Tom &amp; Jerry &lt;3](#tom--jerry-3)`, followed by
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`

### Requirement: Plain text of the heading

The text of every TOC entry SHALL be the heading text as GitHub renders it, with all
HTML tags removed. The text inside link, image, formatting and inline HTML elements
(such as `<a>`, `<em>`, `<strong>`, `<sub>`) SHALL be kept. HTML entities SHALL stay as
GitHub renders them (`&amp;`, `&lt;`), and the spaces around a removed element SHALL
stay as they are. Entries of headings without HTML tags SHALL NOT change. This SHALL
apply to every input: stdin, a local file, a remote URL, several inputs, `--insert` and
`--stdout`.

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
