# Design

## Context

See proposal.md - Why for the symptoms and specs/toc-markers/spec.md for requirements.

The markers are checked with `grep -Fxq`, a whole line equal to the marker, in three
places, and then `sed` finds them as a substring of any line:

```
                     check (grep -Fxq)                 edit (sed)
--skip-header        gh_toc_md2html: "<!--te-->"       sed '1,/<!--te-->/d'
--insert             gh_toc: "<!--ts-->", "<!--te-->"  sed /<\!--ts-->/,/<\!--te-->/{//!d;}
                                                       sed /<\!--ts-->/r <toc_path>
--stdout             gh_toc_stdout: the same two       the same two sed, without -i
```

Running the same `sed` commands on a CRLF file removes the old lines between
`<!--ts-->\r` and `<!--te-->\r` and inserts the TOC file after `<!--ts-->\r`. So only the
check rejects such a file. The inserted lines are the bytes of the TOC file, which ends
every line with `\n`.

Before `sed`, `gh_toc` writes the TOC file `${toc_path}` (`<file>.toc.<date>`, next to
the file) and `gh_toc_stdout` writes `${gh_tmp_toc}` (from `gh_toc_mktemp`, removed by the
`trap` on exit): `echo "${toc}"`, then, without `--hide-footer`,
`echo -e "\n${toc_createdby}\n${toc_footer}\n"`.

For CRLF input, the GitHub API returns no `\r` in the rendered headings, so the TOC lines
have no `\r` (checked with `od -c`).

Constraints: BSD grep, sed and awk on macOS, GNU grep and sed with mawk or gawk on Linux,
OS/390, `make lint` (shellcheck).

## Goals / Non-Goals

**Goals:**

- Change only the five `grep` checks and add a step after the TOC file is written; leave
  the `sed` commands as they are.
- For files where the marker lines are exactly the markers, run no new code after the
  check, so their result stays byte-for-byte the same.

**Non-Goals:**

- New fixtures: the tests write their files into `$BATS_TEST_TMPDIR` with `printf`, as
  the #75 and #113 tests do. The repository has no `.gitattributes`, but a CRLF file
  created by the test cannot be changed by a git setting either.

## Decisions

### `grep -Eq '^<!--ts-->[[:space:]]*$'` for every check

Replace each `grep -Fxq "<!--ts-->"` with `grep -Eq '^<!--ts-->[[:space:]]*$'`, and the
same for `<!--te-->`: two calls in `gh_toc`, two in `gh_toc_stdout`, one in
`gh_toc_md2html`. `[[:space:]]` is POSIX and has the space, the tab and the carriage
return. `<`, `!` and `-` are not special in an ERE, and the single quotes keep the pattern
as it is.

Checked with BSD grep 2.6.0 and GNU grep 3.11 on the lines `<!--ts-->`, `<!--ts-->\r`,
`<!--ts-->  \t`, `    <!--ts-->` and `see <!--ts--> here`: the first three match, the
last two do not.

Alternatives considered:

- `grep -Fxq` with and without a `\r` at the end: covers CRLF, but not trailing spaces,
  which fail in the same way.
- Remove `\r` from the file before the check: `--insert` would have to change the file or
  check a copy, and `sed` still works on the original bytes.
- A function for the check: five calls with the same short pattern; inline changes keep
  the diff to the lines that change.

### CRLF: add `\r` to every line of the TOC file with `awk`

In `gh_toc` and `gh_toc_stdout`, after the TOC file is written and before `sed` reads it,
when the `<!--ts-->` line of the input ends with a carriage return
(`grep -Eq '^<!--ts-->[[:space:]]*'$'\r''$'`), rewrite the TOC file with
`awk '{print $0 "\r"}'` into `<TOC file>.crlf` and move it over the TOC file. The writes
of the TOC and the footer stay as they are. For other files this step does not run.

`"\r"` in an awk string is POSIX. Checked with BSD awk 20200816 and mawk:
`a\n\nb\n` becomes `a\r\n\r\nb\r\n`, also for the empty line. Since the TOC lines have
no `\r`, every line gets exactly one.

In `gh_toc_stdout`, add `${gh_tmp_toc:+"$gh_tmp_toc.crlf"}` to the `trap`, so the copy is
removed also when the program exits between `awk` and `mv`, as `toc-stdout` (Source is
not changed) requires for temporary files.

Alternatives considered:

- `sed 's/$/\r/'`: BSD sed writes a literal `r`, not a carriage return.
- Write the TOC and the footer through `awk` with an `eol` variable that is `\r` or empty:
  changes the existing write lines in both places and runs `awk` for every file.
- Add `\r` in bash, with `${toc//$'\n'/$'\r\n'}` for the TOC and `\r` in the `echo -e` of
  the footer: two ways for one result, and the footer string gets harder to read.
- Decide by the whole file (for example, most lines end with `\r`): more code for files
  with mixed line endings, which this change does not try to fix.

### Tests

New tests write their files into `$BATS_TEST_TMPDIR` with `printf`:

- "Insert into a file with CRLF line endings, #119": `--insert --no-backup`, with the
  footer; asserts lines 2, 3, 5 and 8 with `$'\r'` at the end, and that no line of the file
  lacks `\r` (`grep -vc $'\r$'` is `0`).
- "Whole file with TOC to stdout for CRLF line endings, #119": `run_to_files
  --hide-footer --stdout`; compares `out.md` with the expected bytes using `cmp`.
- "TOC with skip headers for CRLF line endings, #119": `--skip-header`; asserts that
  `${lines[2]}` is `* [Title](#title)`, `${lines[3]}` is `   * [Section](#section)` and
  `${lines[4]}` is the `Created by` line. The file has two headings after `<!--te-->`:
  with one, the HTML from the API is one line, and `gh_toc_grab` gives an empty TOC on
  macOS (BSD sed `N` on the last line, #179), with or without this change.
- "Insert with trailing whitespace after the markers, #119": `--insert --no-backup
  --hide-footer`; compares the file with the expected bytes using `cmp`.
- "Error for indented markers, #119": `run_to_files --insert --no-backup --hide-footer`;
  asserts the exit code 1, the error line in `out.md`, and that the file is unchanged.

The first four fail before the change: the first, the second and the fourth with the
error, the third with `* [Header](#header)` as `${lines[2]}`. The last one passes before
and after: it keeps indented markers rejected.

## Risks / Trade-offs

- [`<TOC file>.crlf` stays next to the file when `awk` or `mv` fails during `--insert`] →
  Like the `.toc.<date>` file, which also stays when the command fails after it is
  written. `--stdout` removes its copy with the `trap`.
- [Mixed line endings, for example `<!--ts-->\r` with `\n` on other lines] → The `<!--ts-->`
  line decides, as the spec says; other lines are not changed.
- [OS/390: `grep -E` with `[[:space:]]` and `"\r"` in awk are not checked there] → Both
  are POSIX. Not checked locally.
- [Several marker pairs, markers in code blocks] → Unchanged by this change, see #194.
