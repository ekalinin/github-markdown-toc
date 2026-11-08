# Proposal

## Why

The TOC entry of a heading with inline code has no backticks (#153, open since 2024):
`` # `Headline` `` gives `* [Headline](#headline)`. The reporter's linter fails on such
entries in CI. The `<code>` tags have been removed from the entries since the fix of #13
(1056956), and since #185 every tag of the heading text is removed in awk as well.

Without the backticks, the code is read as markdown in the TOC. Reproduced with the
current master: `` ## `**kwargs**` `` gives `* [**kwargs**](#kwargs)`, which GitHub
renders as a bold "kwargs" without the asterisks.

The reporter asks for an option, so that the entries do not change for the users who want
the code without backticks.

## What Changes

- New option `--keep-code`. With it, every inline code element of the heading text is
  written into the TOC entry as a markdown code span with the same content:
  - `&lt;`, `&gt;` and `&amp;` inside the code are written as `<`, `>` and `&`: in a code
    span they are not decoded;
  - the span is enclosed in one backtick more than the longest run of backticks inside
    the code;
  - one space is added on each side when the code starts or ends with a space or a
    backtick and is not only spaces.

  For example, `` # `Headline` `` gives `` * [`Headline`](#headline) ``, and
  `` ## `a<b>&c` `` gives `` * [`a<b>&c`](#abc) ``. The rest of the text and the link of
  the entry stay as without the option.
- `--keep-code` applies to every input: stdin, a local file, a remote URL, several
  inputs, `--insert` and `--stdout`.
- `--keep-code` is parsed right after `--bullet` and before `-`, so it works with stdin.
- `--help`: a new line for `--keep-code` right after `--bullet`.
- README: a sentence and an example after the `--bullet` example, without a new heading.
- Tests: a new fixture with the cases above, the option for a local file, stdin, a
  remote URL and `--stdout`, the same fixture without the option, and an updated
  `test_help`.

Without `--keep-code`, the output does not change.

Non-goals:

- Keeping the backticks by default: #153 asks for an option.
- Writing other markup back as markdown (`*em*`, `**strong**`, links): #153 asks for the
  code only.
- Headings that are missing from the TOC when GitHub puts a line break after the heading
  tag (#201): a separate bug, also without `--keep-code`.
- Backslash sequences in the heading text, such as `\n`, which the final `echo -e` of
  `gh_toc_grab` turns into control characters: the same with and without `--keep-code`.
- Changes to the landing page (`site/`) or `openspec/specs/landing`.
- A version bump.

## Capabilities

### New Capabilities

- `toc-keep-code`: the `--keep-code` option: how the inline code of a heading is
  written into its TOC entry, the inputs it applies to, the option order, and `--help`.

### Modified Capabilities

- `toc-heading-markup`: "Plain text of the heading" states that all HTML tags of the
  heading text are removed; with `--keep-code`, the inline code is written as described
  in `toc-keep-code`.

## Impact

- `gh-md-toc`: `gh_toc_app` (parse `--keep-code`, pass it on), `gh_toc` and
  `gh_toc_stdout` (a new last parameter), `gh_toc_grab` (a new parameter, the `<code>`
  `sed` step and the awk script), `show_help`.
- `tests/tests.bats`: new tests, a new fixture `tests/test directory/test_keepcode.md`,
  and an updated `test_help` (20 lines instead of 19).
- `README.md`: a sentence and an example only, no new heading, so the README TOC
  asserted in `tests/tests.bats` does not change.
- The Docker image (Debian, `awk` is mawk) gets the same output as macOS (BSD awk).
- Closes #153.
