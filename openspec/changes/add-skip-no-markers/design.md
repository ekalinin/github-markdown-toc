# Design

## Context

See proposal.md - Why for the symptoms and specs/toc-skip-no-markers/spec.md for the
requirements.

`gh_toc_app` parses the options once each, in a fixed order: `--indent`, `--depth`,
`--numbered`, `--bullet`, `-`, `--insert`, `--no-backup`, `--hide-footer`, `--stdout`,
`--skip-header`, then the inputs. `--no-backup` and `--hide-footer` set
`need_replace="yes"`. With `--stdout`, `gh_toc_app` calls `gh_toc_stdout` and returns;
otherwise it calls `gh_toc` once per input, with `$#` as the number of inputs.

`gh_toc` takes 10 positional parameters, the last one is `bullet`. For a local file it
works in this order:

```
gh_toc <input> ...
   |
   +--> one input: print "Table of Contents", "=================", ""
   |
   +--> remote URL: gh_toc_load | gh_toc_grab   -> stdout
   |                with --insert: "!! '<url>' is not a local file"
   |
   +--> local file: gh_toc_md2html               -> GitHub API request
                    gh_toc_grab, echo "$toc"     -> stdout
                    with --insert: marker check  -> "You don't have ..." + exit 1
                                   sed -i, backup and TOC files, "!! TOC was added"
```

The `exit 1` of the marker check ends the whole program, so the loop in `gh_toc_app` does
not reach the next inputs.

The marker lines are checked with
`grep -Eq '^<!--ts-->[[:space:]]*$'` and `grep -Eq '^<!--te-->[[:space:]]*$'` in three
places: `gh_toc_md2html` (`--skip-header`), `gh_toc` (`--insert`) and `gh_toc_stdout`
(`--stdout`), see `toc-markers`.

Constraints: BSD and GNU tools, the OS/390 branch, `make lint` (shellcheck).

## Goals / Non-Goals

**Goals:**

- Decide about a skipped file before anything is printed or sent for it.
- Keep the code paths without `--skip-no-markers` as they are.

**Non-Goals:**

- A shared function for the four marker checks: the three existing checks stay as they
  are.

## Decisions

### The check at the top of `gh_toc`

With `--skip-no-markers`, `gh_toc` checks the markers right after the check for an empty
input and before the "Table of Contents" header, for a local input only
(`gh_is_url` is not `yes`) that is an existing file (`[ -f "$gh_src" ]`). When a marker
line is missing, it prints the warning to stderr and returns. The rest of `gh_toc` does
not change.

```
gh_toc <input> ...
   |
   +--> --skip-no-markers, local, existing file, no marker line:
   |       "<input>: Warning: no <!--ts--> or <!--te--> in the file, skipped" >&2
   |       return 0
   |
   +--> as before
```

So a skipped file gets no header, no GitHub API request, no backup and TOC files, and
the loop goes on to the next input. `return` gives 0, and the exit code of the program
stays the one of its last command.

Alternatives considered:

- The check in the local branch, before `gh_toc_md2html`: the header is already printed,
  so one skipped file would leave "Table of Contents" with no entries on stdout.
- Filter the inputs in `gh_toc_app` before the loop: `$#` would drop, and with it the
  "Table of Contents" header and the link prefix of the other inputs, e.g. a remote URL
  given with one skipped file would lose its prefix. The spec keeps the other inputs as
  before.
- Replace the `exit 1` of the existing check with a `return`: the TOC is already printed
  and the API request is already sent by then.

### The same regexes, inline

The check uses the same two `grep -Eq` calls as `gh_toc_stdout`, so a file is skipped by
exactly the lines `--insert` looks for (`toc-markers`). It is written inline, like the
three existing checks.

Alternative: a function such as `gh_toc_has_markers` for all four checks. It would touch
the three existing checks, which this change does not need.

### Only an existing file is skipped

The `[ -f "$gh_src" ]` part keeps a missing path, a directory and `-` out of the skip:
they go the same way as before, and a missing path still exits with code 1. Without it,
`grep` would fail on a missing path, the file would be skipped with exit code 0, and a
typo in a CI command would pass unnoticed.

### Parsing and passing the option

`gh_toc_app` gets `local skip_no_markers=""` next to `local to_stdout=""`, and a check
right after `--hide-footer`:

```bash
if [ "$1" = '--skip-no-markers' ]; then
    need_replace="yes"
    skip_no_markers="yes"
    shift
fi
```

`need_replace="yes"` is what `--no-backup` and `--hide-footer` do to turn on `--insert`.
The value goes to `gh_toc` as a new last (11th) parameter, read as
`local skip_no_markers=${11}`.

### The error with `--stdout`

The option is parsed before `--stdout`, so the error is checked in the `--stdout` branch
of `gh_toc_app`, before the existing check of the inputs: the message
`--skip-no-markers cannot be used with --stdout.` goes to stderr and the program exits
with 1. Stderr follows `toc-stdout` (Errors on stderr): with `--stdout`, every error goes
to stderr. The check comes before `gh_toc_stdout`, so there is no network call.

### The warning

`<input>: Warning: no <!--ts--> or <!--te--> in the file, skipped` follows the form of the
skipped level warning (#75), `<input>: Warning: ...`, and goes to stderr like it. Unlike
that warning, it has the input also with one input: the point of the warning is which
file was skipped. Stdout keeps only the TOC and the `!!` lines.

### Help, README

`show_help` gets
`  --skip-no-markers   Skip files without <!--ts--> or <!--te-->. Set --insert as well. Default: false.`
right after the `--hide-footer` line. The description starts at the same column as the
other options, and "Set --insert as well" is the wording of `--no-backup` and
`--hide-footer`.

README, section "Auto insert and update TOC": after the paragraph "Next time when your
file will be changed just repeat the command ...", a sentence about
`--skip-no-markers` and the example
`find . -name '*.md' -exec ./gh-md-toc --insert --no-backup --hide-footer --skip-no-markers {} +`.
No new heading, so the README TOC in `tests/tests.bats` does not change.

### Tests

The new tests write their files into `$BATS_TEST_TMPDIR` with `printf` and run
`run_to_files`, as the #113 and #119 tests do:

- "Several files" and "Several files without the option": `a.md`, `b.md`, `c.md` as in
  the spec, the files compared with `cmp` and stdout with `grep -Fxc`. Two GitHub API
  requests each.
- "One file with one marker": `GH_TOC_TOKEN=invalid`, the file in its own directory, so
  `ls` shows that no backup or TOC files were created. With a request to the API, the
  invalid token would give exit code 1, so the test also shows that there is no request.
  No network.
- "Missing file", "With --stdout": no network.
- "Without --insert": one GitHub API request; the backup and TOC files stay in
  `$BATS_TEST_TMPDIR`.
- `test_help`: the new line at index 15, `--stdout` and `--skip-header` at 16 and 17, 19
  lines in total.

Before the implementation, `--skip-no-markers` is taken as an input, a missing file, so
the program exits with 1 on it. So "Several files", "One file with one marker",
"With --stdout", "Without --insert" and `test_help` fail before the implementation.
"Missing file" and "Several files without the option" pass before it: they pin down the
behavior that does not change.

## Risks / Trade-offs

- [A broken marker line, e.g. an indented one, makes a file skipped with exit code 0 in
  CI] → The warning on stderr names the file. Without `--skip-no-markers`, the error and
  exit code 1 stay.
- [`find` also finds files in `node_modules`, `vendor` and the like] → They usually have
  no markers, so they are skipped without API requests. The README example is a starting
  point; `find` options such as `-not -path` narrow it.
- [`--skip-no-markers` after `--stdout` or `--skip-header` is taken as an input] → The
  same limitation applies to every option; `--help` lists the options in the parse order.
- [Three new tests call the GitHub API] → Same as the existing tests: `GH_TOC_TOKEN`
  locally, `secrets.GITHUB_TOKEN` in CI.
