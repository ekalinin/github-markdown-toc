# Proposal

## Why

`--insert` with several local files stops at the first file without the `<!--ts-->` and
`<!--te-->` markers (#110, open since 2021). The files after it are not processed, even
when they have the markers, and the exit code is 1. So `--insert` cannot be run on all
markdown files of a directory, where most files have no TOC. Reproduced with the current
master:

- `a.md` and `c.md` have the markers, `b.md` does not.
  `gh-md-toc --insert --no-backup --hide-footer a.md b.md c.md` inserts the TOC into
  `a.md`, prints `You don't have <!--ts--> or <!--te--> in your file...exiting` for
  `b.md`, exits with 1, and does not change `c.md`.
- The markers are checked after the file is rendered by the GitHub API, so a request is
  spent on `b.md`. Without a token, the limit is 60 requests per hour.

The reporter of #110 works around it in CI with `grep -z` to find the files with both
markers, and `xargs -L 1` to run `gh-md-toc` once per file. PRs #115 and #117 proposed
`--all` to find all markdown files, and `--auto` to add the markers to a file without
them; both were closed without a merge.

## What Changes

- New option `--skip-no-markers`. With it, a local file without a line that counts as
  `<!--ts-->` or without a line that counts as `<!--te-->` (see `toc-markers`) is
  skipped: it is not changed, no request is sent to the GitHub API for it, and a warning
  `<input>: Warning: no <!--ts--> or <!--te--> in the file, skipped` is printed to
  stderr. The other inputs are processed as before.
- When every file is skipped, the exit code is 0.
- `--skip-no-markers` turns on `--insert`, as `--no-backup` and `--hide-footer` do. It
  is parsed right after `--hide-footer` and before `--stdout`.
- `--skip-no-markers` with `--stdout` is an error: the message
  `--skip-no-markers cannot be used with --stdout.` on stderr, exit code 1, before any
  network call.
- A remote URL is not affected: its TOC is printed, followed by `!! '<url>' is not a
  local file`, as before.
- `--help`: a new line for `--skip-no-markers` right after `--hide-footer`.
- README: a sentence and a `find` example in the "Auto insert and update TOC" section,
  without a new heading:
  `find . -name '*.md' -exec ./gh-md-toc --insert --no-backup --hide-footer --skip-no-markers {} +`.
  This covers the first request of #110, the recursive folders.
- Tests for several files, one file without markers, `--skip-no-markers` alone, the error
  with `--stdout`, and an updated `test_help`.

Without `--skip-no-markers`, the output, the exit codes and the stop at the first file
without markers do not change.

Non-goals:

- A directory walk in `gh-md-toc` itself (`--all`, `--recursive`): `find` does it, and
  hidden folders, `node_modules` and symlinks would need their own rules.
- Adding the markers to a file without them (`--auto`, `--head` of #117).
- Skipping files without markers by default, or only when several inputs are given.
- Changes to the landing page (`site/`) or `openspec/specs/landing`.
- A version bump.

## Capabilities

### New Capabilities

- `toc-skip-no-markers`: the `--skip-no-markers` option: which files are skipped, the
  warning, the exit code, and its use with other options.

### Modified Capabilities

- `toc-stdout`: "Help lists the option" states that `--stdout` follows `--hide-footer` in
  `--help`; it follows `--skip-no-markers` now.

## Impact

- `gh-md-toc`: `gh_toc_app` (parse `--skip-no-markers`, the error with `--stdout`, pass
  it on), `gh_toc` (a new parameter and the check before the GitHub API call),
  `show_help`.
- `tests/tests.bats`: new tests on files in `$BATS_TEST_TMPDIR`, and an updated
  `test_help` (19 lines instead of 18). No new fixtures.
- `README.md`: a sentence and an example only, no new heading, so the README TOC asserted
  in `tests/tests.bats` does not change.
- `toc-markers`: not changed. A file is skipped by the same marker lines that `--insert`
  looks for.
- `toc-multiple-inputs`: not changed. The links of a local file with `--insert` and
  several inputs are already `#<anchor>` only (#192), so the TOC written by the `find`
  example works in every file.
- Closes #110.
