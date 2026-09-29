# Proposal

## Why

`gh-md-toc` puts every heading of a document into the TOC, from `h1` to `h6`, and there
is no way to keep only the top levels, e.g. only `#` and `##` (#25, open since 2016).
The Go version (`github-markdown-toc.go`) already has `--depth` for this.

## What Changes

- New option `--depth <NUM>`: the TOC keeps only headings with level `<= NUM`. The level
  is absolute, as in the Go version: `--depth 2` keeps `h1` and `h2`. An empty value or
  `0` means no limit, which is the current behavior.
- The option applies to every input: stdin, local file, remote URL, several inputs, and
  `--insert`.
- `--depth` is parsed in the existing fixed order of options, right after `--indent` and
  before `-`.
- `--help`: a new line for `--depth` right after `--indent`.
- README: an example with `--depth 1` in the "Local files" section, after the existing
  example, without a new heading.
- Tests: a new fixture `tests/test directory/test_depth.md`, a test for a local file, a
  test for stdin, and an updated `test_help`.

Non-goals:

- `--start-depth` (the Go version has it, #25 asks only for the upper bound).
- The `--depth=NUM` syntax.
- Validation of the value (`--indent` is not validated either).
- Changes to indentation: entries stay indented by `(level - 1) * indent` (#30, #75).
- A rewrite of the argument parser so options can come in any order.
- Updating the outdated README examples (#165).

## Capabilities

### New Capabilities

- `toc-depth`: limiting the TOC to headings up to a given level.

### Modified Capabilities

None.

## Impact

- `gh-md-toc`: `gh_toc_app` (parse `--depth` and pass it on), `gh_toc` (new
  parameter), `gh_toc_grab` (one condition in the awk script shared by the default and
  OS/390 branches), `show_help`.
- `tests/tests.bats`: two new tests and an updated `test_help` (15 lines instead of
  14). The new tests call the GitHub API, like the existing local file tests.
- `README.md`: an example only, no new heading, so the README TOC asserted in
  `tests/tests.bats` does not change.
- `openspec/specs/remote-toc` describes the output without `--depth`; its requirements
  do not change. `openspec/specs/landing` does not list options and is not affected.
