# Proposal

## Why

When a heading skips a level (`# First` followed by `### Third`, #75), the TOC entry is
indented by `(level - top) * indent` spaces, 6 with the default indent. GitHub nests a
list item only when it starts at most 3 columns after the text of its parent, so the
entry becomes text of the parent entry and GitHub renders `First * Third` on one line.
Reproduced with the GitHub markdown API:

| marker | indent | `#` -> `###` | `#` -> `####` |
|---|---|---|---|
| `*` | 2 | nested list | one line |
| `*` | 3 (default) | one line | one line |
| `*` | 4 | one line | one line |
| `1.` | 3 | nested list | one line |

This output is what the specs require today: `test_numbered.md` has `# Title two`
followed by `### Skipped`, and `toc-numbered` asserts `      * [2.1. Skipped](#skipped)`.

This change does not change the TOC. It tells the user which heading skips a level, so
the user can fix the headings of the document.

## What Changes

- For every TOC entry whose heading level is more than one level deeper than its parent,
  print one line to stderr. The parent is the nearest previous entry with a lower level,
  the same parent as for `--numbered outline` numbers. For `test_numbered.md`:
  `Warning: heading 'Skipped' (level 3) skips a level after 'Title two' (level 1), see https://github.com/ekalinin/github-markdown-toc/issues/75`
- Entries without a parent (for example `###` before `##`) get no warning.
- With several inputs, the line starts with the input as given and `: `, for example
  `tests/test directory/test_numbered.md: Warning: ...`.
- The TOC does not change: stdout, the TOC that `--insert` writes into the file, and the
  output of `--stdout` stay byte-for-byte the same. The exit code stays the same.
- The warning applies to every input: stdin, a local file, a remote URL, several inputs,
  `--insert` and `--stdout`. With `--depth`, only the entries in the TOC are checked.
- Tests: the 3 existing tests that run `test_numbered.md` without `--depth` keep their
  assertions and run without stderr; new tests for the warning.

Non-goals:

- A change of the TOC for skipped levels: an indent by the depth in the heading tree, an
  indent limited to the parent indent plus `indent`, or placeholder entries for the
  missing levels.
- A warning only when GitHub renders the TOC wrong. That depends on `--indent` and the
  marker: with `--indent 2` or `--numbered list`, one skipped level is still rendered as
  a nested list, and the warning is printed anyway.
- A document whose first heading is deeper than a later one, with `--indent 4` or more
  (the TOC is rendered as a code block, a non-goal of `fix-relative-toc-indent`).
- A remote test: no pinned GitHub page with a skipped level is known (the page from #75
  has no headings now). The remote path uses the same awk code.
- An option to turn the warning off.
- Changes to README, the landing page (`site/`), or `openspec/specs/landing`.
- A version bump.

## Capabilities

### New Capabilities

- `toc-skipped-level`: a warning on stderr for every TOC entry that skips a heading level,
  for every input, without a change of the TOC.

### Modified Capabilities

None. `toc-indent`, `toc-depth`, `toc-numbered`, `toc-bullet` and `remote-toc` describe
the TOC, which does not change. `toc-stdout` requires that nothing else is printed to
stdout, and its "Errors on stderr" covers errors with exit code 1; the warning is not an
error and goes to stderr.

## Impact

- `gh-md-toc`: `common_awk_script` in `gh_toc_grab`, shared by the default and the OS/390
  branches. No new options, no changes in `gh_toc_app`, `gh_toc`, `gh_toc_stdout` or
  `show_help`.
- `tests/tests.bats`: bats `run` merges stderr into `lines`, so the warning would shift
  the line indexes in the tests `TOC as ordered list for local file, #26`,
  `TOC with outline numbers for local file, #26` and
  `TOC with plus bullets and outline numbers for local file, #71`. They run gh-md-toc
  without stderr through a new helper; their assertions do not change. New tests use the
  existing `run_to_files` helper. No new fixture: the other inputs are written with
  `printf`, as in the existing stdin tests.
- Every other fixture, `README.md`, and the remote pages used by the tests have no
  skipped level (checked), so their tests do not change.
