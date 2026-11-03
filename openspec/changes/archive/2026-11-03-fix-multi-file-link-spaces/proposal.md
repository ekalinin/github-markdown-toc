# Proposal

## Why

With several inputs, every TOC entry links to `<input><anchor>`, where `<input>` is the
path as given on the command line. A path with a space gives a link that GitHub does not
render as a link (#76: GitHub wiki pages can have spaces in the name). Reproduced with
0.11.0:

- `gh-md-toc "My Wiki Page.md" "Other Page.md"` gives
  `* [Title](My Wiki Page.md#title)`.
- The GitHub markdown API renders `* [raw space](My Wiki Page.md#title)` as the plain text
  `[raw space](My Wiki Page.md#title)`, and both `(My%20Wiki%20Page.md#title)` and
  `(<My Wiki Page.md#title>)` as `<a href="My%20Wiki%20Page.md#title">`.

The other cases from #76 already work: a single local file with a space in the path and
`--insert` into it (fixed by #136), and a remote wiki page URL with hyphens or `%20`.

## What Changes

- With several inputs, replace every space in the link prefix of a TOC entry with `%20`:
  `* [Title](My%20Wiki%20Page.md#title)`.
- Keep the input as given on the command line everywhere else: the skipped level
  warning still starts with `My Wiki Page.md: `.
- Add a test with two local files from `tests/test directory/`.

Output change: with several inputs, entries of an input whose path has a space change
from `(tests/test directory/test_depth.md#title-one)` to
`(tests/test%20directory/test_depth.md#title-one)`. A TOC that `--insert` put into a file
with several inputs changes on the next run. Output with one input, and entries of inputs
without a space, stay byte-for-byte the same.

Non-goals:

- Encoding other characters in the prefix (`%`, `(`, `)`, `<`, `>`, non-ASCII).
- Encoding spaces in a remote URL before loading it: curl rejects such a URL, and a URL
  copied from a browser already has `%20` or hyphens.
- Wiki-style links (`My-Wiki-Page#title`, without `.md`).
- Changing what the prefix is (the input as given, not its file name).
- Changes to README, the landing page (`site/`), or `openspec/specs/landing`.
- A version bump.

## Capabilities

### New Capabilities

- `toc-multiple-inputs`: the link prefix of TOC entries when more than one input is
  given.

### Modified Capabilities

None. `remote-toc` (Remote page among multiple inputs) stays true: a remote URL that
loads with curl has no space, so its prefix does not change. `toc-skipped-level` (Every
input) requires the warning to start with the input as given, and this change keeps it.

## Impact

- `gh-md-toc`: `common_awk_script` in `gh_toc_grab`, shared by the default and the OS/390
  branches.
- `tests/tests.bats`: one new test. No new fixtures.
- Closes #76.
