# Design

## Context

Every input path ends in `gh_toc_grab`. Its awk script (`common_awk_script`, shared by
the default and the OS/390 branches) picks the start of each entry in one place:

```awk
marker = "* "
prefix = ""
if (numbered == "list") marker = "1. "
if (numbered == "outline") prefix = num " "
```

`--depth` and `--numbered` reach awk as `-v "depth=$3"` and `-v "numbered=$4"`.

`gh_toc_app` checks each option once, in a fixed order: `--indent`, `--depth`,
`--numbered`, then the `--numbered` checks, `-`, `--insert`, `--no-backup`,
`--hide-footer`, `--skip-header`, then the inputs. `gh_toc` takes 9 positional
parameters, the last one is `numbered`.

In CommonMark, `*`, `-` and `+` are bullet markers of the same width, so a TOC with any of
them nests with the same indent and GitHub renders it as the same `<ul>`.

## Goals / Non-Goals

**Goals:**

- One change point for the bullet that covers all inputs, both awk branches and
  `--numbered outline`.
- The output without `--bullet` stays byte-for-byte the same.
- The errors happen before any network call.

**Non-Goals:** see proposal.md - Non-goals.

## Decisions

### One option with a character

`--bullet <CHAR>`, where `CHAR` is the bullet itself: `*`, `-` or `+`. The value is
what the user sees in the output, and the option has the same `<VALUE>` form as
`--numbered <TYPE>`.

Alternatives: a `--dash` flag (no room for `+`), or names like `dash` and `plus` (one
more mapping to learn, and `-` as a value is already handled, see below).

### Empty means "not given"

`gh_toc_app` gets `local bullet=""` next to `local numbered=""`. An empty value means
that `--bullet` was not given, so the check against `--numbered list` needs no extra
flag. `gh-md-toc --bullet "" ...` is then the same as no `--bullet`, like
`--numbered ""` today.

The default `*` stays in awk: the `marker = "* "` line keeps its value, and
`if (bullet != "") marker = bullet " "` follows it, before the `list` line. So `list`
still wins in awk, and the error below keeps the two from being combined.

Alternative: set `bullet="*"` in `gh_toc_app` and always pass it on. The check against
`--numbered list` would then need a second variable to know whether `--bullet` was
given.

### `bullet` passed to awk with `-v`

`gh_toc_grab` gets the character as a new fifth argument and passes it as
`-v "bullet=$5"`, next to `depth` and `numbered`. `-v` handles `*`, `-` and `+` as
plain values (checked with BSD awk).

### Parsing and checks in `gh_toc_app`

A `--bullet` check (`bullet="$2"`, `shift 2`) goes right after the `--numbered` check
and before the `--numbered` checks, so `--bullet - -` takes the first `-` as the value
and the second as stdin. Two checks print their message and `exit 1` (see the spec,
Invalid usage):

- right after the `case` for `--numbered`, a `case $bullet in "" | "*" | - | +) ;;`.
  The `*` must be quoted: an unquoted `*` pattern matches every value;
- after the `--numbered list` indent check, `[ "$numbered" = "list" ] && [ -n "$bullet" ]`.

The messages go to stdout, like the existing errors.

The value goes to the stdin branch as
`gh_toc_grab "" "$indent" "$depth" "$numbered" "$bullet"` and to `gh_toc` as a new last
(10th) parameter. In `gh_toc` it is read as `local bullet=${10}`: in bash `$10` is `$1`
followed by `0`. `gh_toc` passes it to both of its `gh_toc_grab` calls.

Alternative: check the value in `gh_toc_grab`. It runs once per input and after the
network call, so an error would come after a request to the GitHub API.

### Existing fixtures

The tests use `test_depth.md` (four levels, no skipped level) for a local file and
stdin, and `test_numbered.md` for `--numbered outline`, whose expected output is already
in `tests/tests.bats` with `*`. No new fixture is needed.

## Risks / Trade-offs

- [`--bullet *` without quotes is expanded by the shell to the file names of the current
  directory] → The value is checked, so the user gets the "Unknown bullet" error with the
  first file name. `*` is the default, so it rarely needs to be given.
- [`--bullet` after another option, e.g. `--insert --bullet - README.md`, is taken as an
  input] → `--help` lists `--bullet` right after `--numbered`, which matches the parse
  order. The same limitation applies to every option.
- [`--bullet ""` is accepted as the default, also with `--numbered list`] → Accepted, see
  the decision above.
- [The new tests for a local file and stdin call the GitHub API] → Same as the existing
  tests: `GH_TOC_TOKEN` locally, `secrets.GITHUB_TOKEN` in CI.
