# Proposal

## Why

`--insert` is the only way to get a file with a refreshed TOC, and it always rewrites the
file in place, creates `.orig.<date>` and `.toc.<date>` files next to it (removed only with
`--no-backup`), and mixes the TOC with status lines on stdout. A script that wants the
result somewhere else, or wants to upload it, has no clean way to get it (#62, open since
2019). For a file that is not local there is no way at all.

## What Changes

- New option `--stdout`. It prints to stdout the whole document with the new TOC between
  `<!--ts-->` and `<!--te-->`: the same content that `--insert` writes into the file.
  Nothing else goes to stdout: no "Table of Contents" header, no status lines, no
  trailing `<!-- Created by ... -->` line after the document.
- The source file is not changed, and no `.orig.<date>` or `.toc.<date>` file is created.
- `--stdout` takes exactly one input: a local file, or `-` for stdin. Stdin covers files
  that are not local: `curl -s <raw-url> | gh-md-toc --stdout - | <upload>`.
- `--hide-footer` and `--skip-header` work with `--stdout` as with `--insert`. `--indent`,
  `--depth`, `--numbered` and `--bullet` apply to the TOC as with `--insert`. `--insert`
  and `--no-backup` given together with `--stdout` do not make the file change.
- `--stdout` is parsed in the existing fixed order of options, right after
  `--hide-footer` and before `--skip-header`:
  `gh-md-toc --hide-footer --stdout --skip-header README.md`.
- Errors in this mode go to stderr, with exit code 1 and nothing on stdout, so that with
  `> out.md` the error text does not end up in `out.md`: no input or more than one input,
  a URL as input, a document without the markers, and the GitHub API errors. The other
  modes keep printing their errors to stdout.
- Stdin is read as is, for `-` too: leading and trailing whitespace of each line is kept,
  and the last line is kept when it has no newline. Today the reader removes them, so an
  indented code line like `    # comment` becomes a heading in the TOC from stdin, and a
  last heading without a newline is lost.
- `--help`: a new line for `--stdout` right after `--hide-footer`.
- README: a paragraph with examples in the "Auto insert and update TOC" section, without
  a new heading.
- Tests: `--stdout` for a local file and for stdin, with `--hide-footer`, the errors, a
  test that the source file is not changed, the stdin reading, and an updated
  `test_help`.

Non-goals:

- A remote URL as input of `--stdout`. A GitHub page is loaded as rendered HTML, there is
  no Markdown source to put the TOC into. Stdin is the way for such files.
- Several inputs in one `--stdout` run.
- An `--output <FILE>` option, or writing the result into a file other than stdout.
- Printing the errors of the other modes to stderr.
- A rewrite of the argument parser or the `--opt=value` syntax.
- A version bump.

## Capabilities

### New Capabilities

- `toc-stdout`: printing the whole document with the new TOC to stdout without changing
  the source, for a local file and stdin, and reading stdin as is.

### Modified Capabilities

None. `openspec/specs/toc-indent`, `toc-depth`, `toc-numbered` and `toc-bullet` list the
inputs and modes their options apply to (stdin, a local file, a remote URL, several
inputs, `--insert`). Their requirements do not change; `toc-stdout` states that these
options apply with `--stdout` too.

## Impact

- `gh-md-toc`: `gh_toc_app` (parse `--stdout`, check its input, call the new mode), a new
  function for the `--stdout` mode, a helper for temporary files taken out of the stdin
  branch of `gh_toc_app` (the OS/390 branch is kept), the stdin reader, `show_help`.
  `gh_toc` and the `--insert` code are not changed.
- `tests/tests.bats`: new tests and an updated `test_help` (18 lines instead of 17). The
  tests for a local file and stdin call the GitHub API, like the existing ones; the
  error tests for the input do not.
- `tests/test directory/`: a new fixture with markers, used by the `--stdout` tests and
  never changed by them.
- `README.md`: a paragraph and examples only, no new heading, so the README TOC asserted
  in `tests/tests.bats` does not change.
- `openspec/specs/remote-toc` and `openspec/specs/landing` are not affected.
