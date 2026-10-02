# Proposal

## Why

`gh-md-toc` always builds the TOC as a bullet list (`* [...]`), and there is no way to
get a numbered TOC (#26, open since 2016). The issue asks for ordered lists, "as
Wikipedia does", and a comment in it shows the expected look with hierarchical numbers
like `4.1.`. Markdown cannot render hierarchical numbers by itself: GitHub shows nested
ordered lists as `1.`, then `i.`, then `a.`. So the two looks need two output types.

## What Changes

- New option `--numbered <TYPE>` with two types:
  - `list`: entries are a markdown ordered list, every marker is `1.`:
    `1. [Title](#title)`. GitHub numbers the items itself.
  - `outline`: entries stay bullets, and a hierarchical number is put at the start of
    the link text: `* [2.1. Section](#section)`.
- In `outline`, the number follows the heading tree, not the heading level: a heading
  right under a heading two levels higher gets the next number of its parent, so `#`
  followed by `###` gives `1.` and `1.1.`, not `1.0.1.`.
- Indentation stays `(level - 1) * indent` spaces for both types.
- The option applies to every input: stdin, local file, remote URL, several inputs, and
  `--insert`. With `--depth`, numbers are given only to the entries that are kept.
- `--numbered` is parsed in the existing fixed order of options, right after `--depth`
  and before `-`.
- Errors, with exit code 1 and no TOC: an unknown type, and `--numbered list` with an
  indent less than 3 (GitHub then renders the nested entries as one flat list).
- `--help`: a new line for `--numbered` right after `--depth`.
- README: a sentence and an example for each type in the "Local files" section, after
  the `--depth` example, without a new heading.
- Tests: a new fixture `tests/test directory/test_numbered.md`, tests for both types,
  for stdin, for both errors, and an updated `test_help`.

Non-goals:

- Taking numbers that are already written in the headings (e.g. `## 1. Introduction`)
  and turning them into list markers (a request from a comment in #26).
- Real counters in `list` (`1.`, `2.`, `3.`): GitHub ignores them, and a marker of two
  digits (`10.`) breaks the nesting of its children with the default indent.
- Hierarchical numbers in `list`.
- An upper bound check of `--indent` for `list` (an indent over 6 also breaks the
  nesting, as an indent over 5 already does for bullets).
- Changes to indentation for skipped heading levels (#30, #75).
- The `--numbered=TYPE` syntax and a rewrite of the argument parser.

## Capabilities

### New Capabilities

- `toc-numbered`: building the TOC as a numbered list (`list`) or with hierarchical
  numbers (`outline`).

### Modified Capabilities

None.

## Impact

- `gh-md-toc`: `gh_toc_app` (parse and check `--numbered`, pass it on), `gh_toc` (new
  parameter), `gh_toc_grab` (the entry format in the awk script shared by the default
  and OS/390 branches), `show_help`.
- `tests/tests.bats`: new tests and an updated `test_help` (16 lines instead of 15).
  The tests for a local file and stdin call the GitHub API, like the existing ones; the
  error tests do not.
- `README.md`: examples only, no new heading, so the README TOC asserted in
  `tests/tests.bats` does not change.
- `openspec/specs/remote-toc` and `openspec/specs/toc-depth` describe the output without
  `--numbered`; their requirements do not change. `openspec/specs/landing` does not list
  options and is not affected.
