# Proposal

## Why

`--insert` and `--stdout` find the `<!--ts-->` and `<!--te-->` markers only when the line is
exactly the marker. In a file with Windows line endings (CRLF), the line is
`<!--ts-->\r`, so they exit with `You don't have <!--ts--> or <!--te--> in your
file...exiting`, although the file has the markers (#119, and #86 before it). The TOC
itself is built for such a file: the GitHub API renders CRLF input. Reproduced with the
current master:

- `printf '<!--ts-->\r\n<!--te-->\r\n\r\n# Title\r\n' > f.md`, then
  `gh-md-toc --insert f.md` and `gh-md-toc --stdout f.md` print the error and exit with 1;
  `gh-md-toc f.md` prints `* [Title](#title)`.
- `grep -Fxq "<!--ts-->"`, used for the check, does not match `<!--ts-->\r` with GNU grep
  3.11 or BSD grep 2.6.0; `grep -F` without `-x` does. This is what #119 reports.
- The `Readme.md` of the #119 reporter, committed two minutes after the issue, has CRLF
  line endings on all 252 lines.
- `--skip-header` uses the same check for `<!--te-->`: with CRLF it does not skip the
  headings above the TOC, and prints no error.

The same check fails for trailing spaces after a marker.

## What Changes

- A line counts as a marker when it starts with `<!--ts-->` or `<!--te-->` and has only
  whitespace after it: spaces, tabs, a carriage return. A line with anything before the
  marker, such as indentation, still does not count. This applies to `--insert`,
  `--stdout` and `--skip-header`.
- When the `<!--ts-->` line ends with a carriage return, every line put between the
  markers ends with `\r\n`: the TOC, the empty lines and the footer. The file keeps CRLF
  line endings on every line. Otherwise these lines end with `\n`, as before.
- Add tests with CRLF files, trailing spaces after the markers, and indented markers.

Output change: files with CRLF line endings or with trailing whitespace after a marker now
get a TOC instead of the error, and `--skip-header` skips the headings above `<!--te-->`
in them. Files where the marker lines are exactly the markers give byte-for-byte the same
result as before.

Non-goals:

- Several `<!--ts-->` / `<!--te-->` pairs in one file, and markers inside code blocks
  (#194).
- Converting the line endings of other lines of the file.
- Changes to README, the landing page (`site/`), or `openspec/specs/landing`.
- A version bump.

## Capabilities

### New Capabilities

- `toc-markers`: which lines count as the `<!--ts-->` and `<!--te-->` markers, and the line
  endings of the lines put between them.

### Modified Capabilities

None. `toc-stdout` (Errors on stderr) stays true: a `<!--ts-->` line is now a line that
counts as the marker under `toc-markers`, and the error and its exit code do not change.

## Impact

- `gh-md-toc`: the marker checks in `gh_toc_md2html` (`--skip-header`), `gh_toc`
  (`--insert`) and `gh_toc_stdout` (`--stdout`), and the TOC file that `gh_toc` and
  `gh_toc_stdout` write before `sed` puts it between the markers.
- `tests/tests.bats`: new tests. No new fixtures.
- Closes #119.
