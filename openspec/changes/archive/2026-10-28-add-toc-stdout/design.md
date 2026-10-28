# Design

## Context

`gh_toc` handles one input. For a local file it renders the file with the GitHub API
(`gh_toc_md2html`), checks the result (`gh_toc_check_api_error`), extracts the TOC
(`gh_toc_grab`) and prints it. With `--insert` it then:

```bash
sed -i"${ext}" "/${ts}/,/${te}/{//!d;}" "$gh_src"     # clear the old TOC
echo "${toc}" > "${toc_path}"                          # TOC block, next to the file
echo -e "\n${toc_createdby}\n${toc_footer}\n" >> "$toc_path"   # unless --hide-footer
sed -i "/${ts}/r ${toc_path}" "$gh_src"                # BSD: sed -i ""
```

Around this, `gh_toc` prints the `Table of Contents` header (one input only), the TOC,
`Found markers` and `!! ...` status lines, and `gh_toc_app` prints an empty line before
each input and the `<!-- Created by ... -->` line after all of them. All of it goes to
stdout, the errors too.

`gh_toc_app` checks the options once, in a fixed order: `--indent`, `--depth`,
`--numbered`, `--bullet`, their checks, then `-` (stdin, TOC only, returns), `--insert`,
`--no-backup`, `--hide-footer`, `--skip-header`, then the inputs. The `-` branch copies
stdin into a temporary file with `while read -r input; do echo "$input" >> ...; done`,
created with `mktemp`, or with a timestamp name on OS/390, and never removes it.

`gh_toc_md2html` with `--skip-header` greps `"$gh_src"`, not its own argument, for
`<!--te-->`. It works because bash locals have dynamic scope and the caller `gh_toc` has a
local `gh_src`.

## Goals / Non-Goals

**Goals:**

- The `--insert` code path, the `-` option order and all current outputs stay as they
  are, except the stdin reading (see proposal.md - What Changes).
- The output of `--stdout` is byte-for-byte what `--insert` writes, on BSD and GNU sed.
- The usage errors and the missing markers are found before any network call.

**Non-Goals:**

- Removing the temporary file of the TOC-only `-` mode, which stays in `$TMPDIR` as
  today.
- Fixing `gh_toc_md2html` to grep its own argument.
- An empty TOC for a document whose rendered HTML is a single line, e.g. `# A` alone, on
  BSD sed: the `:a;N;$!ba` joins in `gh_toc_grab` print nothing for one line. It is not
  caused by this change, the tests use documents with two or more headings.
- See also proposal.md - Non-goals.

## Decisions

### A separate function, `gh_toc` is not changed

The mode lives in a new `gh_toc_stdout` (one input, prints the document), called from
`gh_toc_app`. It repeats three calls of `gh_toc` (`gh_toc_md2html`,
`gh_toc_check_api_error`, `gh_toc_grab` with an empty URL, so the links are `#<anchor>`)
and the two footer strings.

Alternative: a third value of `need_replace` (`stdout`) inside `gh_toc`. It needs a
condition in five places: the header, `echo "$toc"`, the URL branch, the destination of
the errors and the write itself, and it mixes the new mode into the `--insert` code. The
"same content as `--insert`" test catches any drift between the two copies of the TOC
block.

### The same sed expressions, without `-i`

```bash
sed "/${ts}/,/${te}/{//!d;}" "$gh_src" | sed "/${ts}/r ${gh_tmp_toc}"
```

These are the `--insert` expressions and the same `ts` and `te` values, so the result is
the same, including the case of more than one `<!--ts-->`. Without `-i` there is no
BSD/GNU difference, so no `sed --version` probe. Both seds keep a last line without a
newline. The TOC block is written to `gh_tmp_toc` with the same `echo` commands as
`--insert`, because `r` reads a file.

Alternatives: awk with the TOC passed by `-v` (awk turns the `\` sequences of the TOC
into other bytes and adds a newline to the last line), `r /dev/stdin` (not known to work
on z/OS), a bash read loop (slow, and loses bytes like the current stdin reader).

### Option order and the stdout branch

`--stdout` is checked right after `--hide-footer` and sets `local to_stdout="yes"`. Right
after the `--skip-header` check, and before the loop over the inputs, a branch for
`to_stdout`:

1. With `$# -ne 1`, or a URL by `gh_is_url`, prints
   `--stdout works with one local file or '-' (STDIN) only.` to stderr and exits with 1.
2. Calls `gh_toc_stdout "$1" "$no_footer" "$indent" "$skip_header" "$depth" "$numbered" "$bullet"`
   and returns, so the empty lines and the `<!-- Created by ... -->` line of the loop are
   not printed.

`--insert`, `--no-backup` and `--hide-footer` still set `need_replace="yes"` before it,
but `need_replace` is only read in the loop, which is not reached.

The `-` check of the TOC-only mode stays before `--insert`. With `--stdout`, `$1` is not
`-` at that point, so `-` reaches the new branch as the input.

Alternative: move the `-` check after `--skip-header` for both modes. Then `--insert -`,
`--hide-footer -` and `--skip-header -` would go to the TOC-only branch; today they take
`-` as an input name and go to `gh_toc`. That is a change of the current modes this
issue does not need.

### `gh_toc_stdout`

1. Sets `trap 'rm -f "$gh_tmp_stdin" "$gh_tmp_toc"' EXIT` first. The two variables are
   global, not local: the trap runs when the script exits, after `gh_toc_app` has
   returned, also on an `exit 1` from a check.
2. Names its input local `gh_src`, for `gh_toc_md2html` (see Context). For `-` it copies
   stdin into `gh_tmp_stdin` and sets `gh_src` to it.
3. Checks `grep -Fxq` for `<!--ts-->` and `<!--te-->` in `gh_src`, as `--insert` does,
   and prints the same message to stderr with `exit 1`. This is before the API call.
4. `rawhtml=$(gh_toc_md2html "$gh_src" "$skip_header")`, then
   `gh_toc_check_api_error "$rawhtml" >&2`. The redirect sends every message of the
   function to stderr, its `exit 1` included, and the function itself is not changed, so
   the other modes keep printing to stdout.
5. Writes the TOC block to `gh_tmp_toc` and prints the result with the sed pipeline.

### A helper for temporary files

The temporary file code of the `-` branch moves into `gh_toc_mktemp`, which prints the
path of a new empty file: `$TMPDIR` (or `/tmp`, created when missing), `mktemp`, and the
OS/390 branch. The `-` branch and `gh_toc_stdout` use it.

`--stdout -` makes two temporary files in one run, and the OS/390 name
`tmp.<timestamp>` is the same for both when they are made in the same second. The OS/390
name becomes `tmp.<timestamp>.$$.$RANDOM`.

Alternative: a copy of the code in `gh_toc_stdout`. Two copies of the OS/390 branch,
which cannot be tested in CI.

### Stdin read with `cat`

Both stdin paths copy stdin with `cat > "$gh_tmp_md"`. `read -r` with the default `IFS`
removes the leading and trailing whitespace of each line and drops a last line without a
newline, and `echo "$input"` drops a line that is `-e`, `-n` or `-E`.

Alternative: `while IFS= read -r input || [ -n "$input" ]; do printf '%s\n' ...`. Longer,
and it still adds a newline to the last line, which breaks the byte-for-byte output of
`--stdout -`.

### Tests

- A new fixture `tests/test directory/test_stdout.md` with markers, an old TOC entry, an
  indented code line that looks like a heading, and a last line without a newline. No
  test writes into it. The existing marker fixtures (`test_filepathwithspace.md`,
  `test_setextwithformatting.md`) are rewritten in place by their `--no-backup` tests.
- `run` in bats merges stderr into `$output` and drops the trailing newline. The tests
  that need the exact bytes or a separate stderr run the command with `bash -c`, write
  stdout and stderr into files in `$BATS_TEST_TMPDIR` (bats 1.4+, CI uses 1.6.0) and
  compare them with `cmp` or `cat`.
- The "same content as `--insert`" test runs `--insert --no-backup --hide-footer` on a
  copy in `$BATS_TEST_TMPDIR`, so the fixture is not changed.

## Risks / Trade-offs

- [`gh-md-toc --stdout README.md > README.md` empties the file before it is read, the
  shell truncates it first] → README says to use `--insert` to update the file in place,
  or to redirect into another file.
- [An editor or a formatter adds the missing newline at the end of `test_stdout.md`] →
  The "Local file" test compares with `cmp` against the exact expected bytes, so it fails
  and points at the fixture. A comment in the test says why the newline is missing.
- [`--skip-header --stdout` is taken as an input, because `--stdout` is checked before
  `--skip-header`] → `--help` lists `--stdout` right after `--hide-footer`, which matches
  the parse order. The same limitation applies to every option.
- [With `--skip-header`, `gh_toc_md2html` writes `<file>~~` next to the source for the
  time of the API call] → Existing behavior of `--skip-header`, the file is removed right
  after the call, so no new file is left.
- [The `--hide-footer` help line says "Set --insert as well", but with `--stdout` the file
  is not changed] → The line is not changed (it is asserted in `test_help`). The
  `--stdout` help line says that the file is not changed, and README describes
  `--hide-footer` with `--stdout`.
- [The TOC from stdin changes for documents with indented lines that look like headings,
  or a last heading without a newline] → It now matches the TOC of the same local file.
  The proposal lists it as a change.
- [The new tests for a local file and stdin call the GitHub API] → Same as the existing
  tests: `GH_TOC_TOKEN` locally, `secrets.GITHUB_TOKEN` in CI. The tests for the input
  and the markers fail before the API call.
