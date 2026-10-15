# Proposal

## Why

The indent of a TOC entry is `(level - 1) * indent` spaces, counted from `#` even when the
document has no `#` heading (#30). When the first entry gets 4 or more spaces, GitHub
renders the whole TOC as a code block instead of a list. Reproduced with 0.10.0 and the
GitHub markdown API:

- `### Foo`, `#### Bar` with the default indent: the first entry has 6 spaces, the TOC
  is rendered as `<pre><code>` (also with `--insert`).
- `## Foo`, `### Bar` with `--indent 4`: the first entry has 4 spaces, the TOC is
  rendered as `<pre><code>`.

The example from the issue (`## Foo`, `### Bar` with the default indent) is rendered as a
list today, because the first entry has 3 spaces, but the cause is the same.

## What Changes

- Indent every TOC entry by `(level - top) * indent` spaces, where `top` is the smallest
  heading level among the entries of the same document. For a document with a `#`
  heading the output stays byte-for-byte the same.
- Add a test fixture without a `#` heading and tests for a local file, stdin with
  `--indent 4`, and stdin with `--depth`.

Output change: for a document without a `#` heading, every entry moves left by
`(top - 1) * indent` spaces. A TOC that `--insert` put into such a file changes on the
next run.

Non-goals:

- `--depth`: the level stays absolute, as `toc-depth` requires.
- `--numbered outline` numbers: they already start from `1.` at the top entries.
- Skipped heading levels (e.g. `#` followed by `###`): the indent between entries does
  not change.
- A document whose first heading is deeper than a later one (e.g. `###` before `##`)
  with `--indent 4` or more: the first entry still gets `indent` spaces.
- Changes to README, the landing page (`site/`), or `openspec/specs/landing`.
- A version bump.

## Capabilities

### New Capabilities

- `toc-indent`: indentation of TOC entries relative to the top heading level of the
  document, for every input.

### Modified Capabilities

- `remote-toc`: "TOC for a remote GitHub page" states `(level - 1) * indent`.
- `toc-depth`: "TOC limited by heading level" states `(level - 1) * indent`.
- `toc-numbered`: "Ordered list" and "Hierarchical numbers" state `(level - 1) * indent`.

## Impact

- `gh-md-toc`: the awk script in `gh_toc_grab` keeps the entries and prints them at the
  end, when the top level is known. The same script is used on OS/390. Each input of
  several inputs goes through its own `gh_toc_grab` call, so `top` is per document.
- `tests/tests.bats` and `tests/test directory/`: one new fixture and three new tests.
  Existing fixtures all have a `#` heading, so their assertions do not change.
