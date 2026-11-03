# Proposal

## Why

With `--insert` and more than one input, every TOC entry written into a file links to
`<input>#<anchor>`, where `<input>` is the path as given on the command line. The TOC is
inside that same file, so the link must be `#<anchor>`, as it already is with one input
(#113). Reproduced with the current master:

- `gh-md-toc --insert --no-backup a.md b.md` writes `* [Usage](a.md#usage)` into `a.md`.
  On a GitHub repository this works, but reloads the page.
- In a GitHub wiki (`--insert *.md`, the case from #113), `server.md#...` redirects to
  `raw.githubusercontent.com/.../server.md`: the reader gets the raw markdown, not the
  section.
- `gh-md-toc --insert docs/c.md docs/d.md` writes `* [Usage](docs/c.md#usage)` into
  `docs/c.md`. The link is relative to `docs/`, so it points to `docs/docs/c.md` on any
  host.

## What Changes

- With `--insert`, every TOC entry of a local file links to `#<anchor>` only, for any
  number of inputs: in the file and in the TOC printed on stdout for that file.
- The skipped level warning still starts with `<input>: ` when there is more than one
  input.
- Entries of a remote URL keep the prefix: nothing is inserted for them, and the printed
  links must lead to the page.
- Without `--insert`, nothing changes: entries keep `<input>#<anchor>` with `%20` for
  spaces (#190).
- Add a test with two local files and `--insert`.

Output change: a TOC that `--insert` put into a file with several inputs changes on the
next run, from `(a.md#usage)` to `(#usage)`. Output without `--insert`, and `--insert`
with one input, stay byte-for-byte the same.

Non-goals:

- A new option to control the prefix.
- Wiki-style links (`server#anchor`, without `.md`) in the output without `--insert`.
- Changing the prefix without `--insert`, for example making it relative to the file.
- Changes to README, the landing page (`site/`), or `openspec/specs/landing`.
- A version bump.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `toc-multiple-inputs`: the link prefix with several inputs no longer applies to the TOC
  of a local file with `--insert`; a new requirement covers `--insert` with several
  inputs.

`toc-skipped-level` (Every input) stays true: the warning keeps `<input>: ` with several
inputs, also with `--insert`. `remote-toc` (Remote page among multiple inputs) stays true:
the entries of a remote URL keep the prefix.

## Impact

- `gh-md-toc`: `gh_toc` (the call of `gh_toc_grab` for a local file) and `gh_toc_grab`
  (`common_awk_script`, shared by the default and the OS/390 branches).
- `tests/tests.bats`: one new test. No new fixtures.
- Closes #113.
