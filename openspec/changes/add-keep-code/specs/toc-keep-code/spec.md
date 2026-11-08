# Spec Delta

## Purpose

Lets the TOC entry of a heading with inline code keep that code in backticks, so the
entry shows the code as the heading does and linters that compare them pass.

## ADDED Requirements

### Requirement: Inline code in backticks

With `--keep-code`, every inline code element of the heading text, as GitHub renders it,
SHALL be written into the TOC entry as a markdown code span with the same content:

- `&lt;`, `&gt;` and `&amp;` inside the code SHALL be written as `<`, `>` and `&`;
- the code SHALL be enclosed in a run of backticks one longer than the longest run of
  backticks inside the code;
- when the code starts or ends with a space or a backtick and is not only spaces, one
  space SHALL be added on each side, between the backticks and the code.

The text outside the inline code SHALL be the same as without `--keep-code`, as in
`toc-heading-markup`: tags removed and HTML entities as GitHub renders them. The link of
the entry SHALL be the same as without `--keep-code`.

#### Scenario: Headings with inline code

- **WHEN** the user runs `gh-md-toc --keep-code "tests/test directory/test_keepcode.md"`,
  where the file has these headings, separated by empty lines:

  ````
  # `Headline`
  ## The command `foo1` is better
  ## `a<b>&c`
  ## `` a`b ``
  ## `` `a` ``
  ## ``` a``b ```
  ## `&lt; &copy;`
  ## `   spaced   `
  ## x ` ` y
  ## `**kwargs**`
  ## Tom & `Jerry` <3
  ## A *em `code`* and [`link`](#headline)
  ````

- **THEN** the TOC entries are these lines, followed by
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`:

  ````
  * [`Headline`](#headline)
     * [The command `foo1` is better](#the-command-foo1-is-better)
     * [`a<b>&c`](#abc)
     * [``a`b``](#ab)
     * [`` `a` ``](#a)
     * [```a``b```](#ab-1)
     * [`&lt; &copy;`](#lt-copy)
     * [`   spaced   `](#--spaced--)
     * [x ` ` y](#x---y)
     * [`**kwargs**`](#kwargs)
     * [Tom &amp; `Jerry` &lt;3](#tom--jerry-3)
     * [A em `code` and `link`](#a-em-code-and-link)
  ````

### Requirement: Every input

`--keep-code` SHALL apply to every input: stdin, a local file, a remote URL, several
inputs, `--insert` and `--stdout`.

`--keep-code` SHALL be accepted after `--indent <NUM>`, `--depth <NUM>`,
`--numbered <TYPE>` and `--bullet <CHAR>` (when given) and before `-`, `--insert`,
`--no-backup`, `--hide-footer`, `--skip-no-markers`, `--stdout`, `--skip-header` and the
inputs.

#### Scenario: Stdin with a bullet

- **WHEN** the user runs
  `cat "tests/test directory/test_backquote.md" | gh-md-toc --bullet - --keep-code -`
- **THEN** the output is these lines:

  ````
  - [The command `foo1`](#the-command-foo1)
     - [The command `foo2` is better](#the-command-foo2-is-better)
  - [The command `bar1`](#the-command-bar1)
     - [The command `bar2` is better](#the-command-bar2-is-better)
        - [The command `bar3` is the best](#the-command-bar3-is-the-best)
  ````

#### Scenario: Remote URL

- **WHEN** the user runs
  `gh-md-toc --keep-code https://github.com/ekalinin/github-markdown-toc/blob/a28f86dcb616ce17103d1dfc28f6c3ac423c388c/tests/test%20directory/test_backquote.md`
- **THEN** the TOC entries are the lines of the scenario "Stdin with a bullet" with `*`
  instead of `-`, and the exit code is 0

#### Scenario: Whole file to stdout

- **WHEN** the user runs `gh-md-toc --keep-code --hide-footer --stdout <dir>/a.md`, where
  `a.md` is ``<!--ts-->\n<!--te-->\n\n# The command `foo1`\n``
- **THEN** stdout is
  ``<!--ts-->\n* [The command `foo1`](#the-command-foo1)\n<!--te-->\n\n# The command `foo1`\n``,
  `a.md` does not change, and the exit code is 0

### Requirement: Without the option

Without `--keep-code`, the TOC entries SHALL be the same as before this change: the
inline code is written without backticks, as in `toc-heading-markup`.

#### Scenario: Headings with inline code without the option

- **WHEN** the user runs `gh-md-toc "tests/test directory/test_keepcode.md"`
- **THEN** the TOC entries are these lines, followed by
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`:

  ````
  * [Headline](#headline)
     * [The command foo1 is better](#the-command-foo1-is-better)
     * [a&lt;b&gt;&amp;c](#abc)
     * [a`b](#ab)
     * [`a`](#a)
     * [a``b](#ab-1)
     * [&amp;lt; &amp;copy;](#lt-copy)
     * [  spaced  ](#--spaced--)
     * [x   y](#x---y)
     * [**kwargs**](#kwargs)
     * [Tom &amp; Jerry &lt;3](#tom--jerry-3)
     * [A em code and link](#a-em-code-and-link)
  ````

### Requirement: Help lists the option

`--help` SHALL list `--keep-code` in the "Options" section right after
`--bullet <CHAR>`.

#### Scenario: Help output

- **WHEN** the user runs `gh-md-toc --help`
- **THEN** the line after
  `  --bullet <CHAR>     Bullet of TOC entries: *, - or +. Default: *.`
  is `  --keep-code         Keep inline code of headings in backticks. Default: false.`
