# Design

## Context

See proposal.md - Why for the symptoms and specs/toc-multiple-inputs/spec.md for
requirements.

With more than one input, `gh_toc` keeps `gh_src_copy` as the input given on the command
line (with one input it sets it to `""`) and passes it to `gh_toc_grab`, which passes it to
awk as `gh_url`. In `common_awk_script`, shared by the default and the OS/390 branches,
`gh_url` is used twice:

```
awk -v gh_url="$1"
   |
   +--> warning: gh_url ": Warning: heading ..."            stderr, #75
   |
   +--> entry:   marker "[" prefix text "](" gh_url modified_href ")"
```

`toc-skipped-level` (Every input) requires the warning to start with the input as given
on the command line, and the test "Warning for skipped heading level for several files,
#75" asserts it with `tests/test directory/test_numbered.md: Warning: ...`.

The whole awk output then goes through `echo -e`, which interprets backslash escapes.

Constraints: BSD awk on macOS, GNU awk on Linux, the same awk code on OS/390,
`make lint` (shellcheck).

## Goals / Non-Goals

**Goals:**

- Change only the link of an entry, in one place that both awk branches share.

**Non-Goals:**

- A new fixture: `tests/test directory/` already has a space in its name.

## Decisions

### Encode the space in awk, when the entry is built

In `common_awk_script`, copy `gh_url` to a new variable, replace every space in the copy
with `gsub(/ /, "%20", ...)`, and use the copy in `entry[count]` instead of `gh_url`. The
warning keeps `gh_url`.

Alternatives considered:

- Encode `gh_src_copy` in bash, in `gh_toc`, before calling `gh_toc_grab`: one line, but
  the warning would show `tests/test%20directory/...` and break the `toc-skipped-level`
  requirement and the #75 test.
- Pass a second, encoded variable from bash to awk (`-v link_url=...`): needs a new
  parameter of `gh_toc_grab` and changes at its call sites for the same result.
- Compute the copy once in a `BEGIN` block: needs a change in both `awkscript` branches,
  since `common_awk_script` is the body of the main block. Doing it per entry costs one
  `gsub` per heading.

### `%20`, not angle brackets

The GitHub markdown API renders both `(My%20Wiki%20Page.md#title)` and
`(<My Wiki Page.md#title>)` as `<a href="My%20Wiki%20Page.md#title">`. `%20` is chosen
because it also works in renderers without angle-bracket link destinations, a `>` in the
path can not end it early, and it is the form a browser shows for such a URL.

`%20` has no backslash, so `echo -e` leaves it as it is. The `+`/`%` conversion of the
anchor (`modified_href`) is not applied to the prefix, before or after this change.

### Only spaces

Full percent-encoding of the path (`%` to `%25`, `(`, `)`, non-ASCII bytes) is much more
awk code and is not what #76 reports. It stays a non-goal.

### Tests

One new test runs `gh_md_toc_no_stderr` with `tests/test directory/test_depth.md` and
`tests/test directory/test_numbered.md` and asserts the entries from the spec scenario
"Two local files in a directory with a space" and the footer. `gh_md_toc_no_stderr` is
needed because the second file has a skipped level, and `run` would merge the warning into
`lines`.

The other scenarios are already covered by existing tests, which stay unchanged:

- "Warning keeps the input as given": "Warning for skipped heading level for several
  files, #75" runs the same command.
- "Input without a space": "TOC for mixed README.md (remote/local)".
- "Local file in a directory with a space": "Toc for file path with space, #136".

Checked on a temporary copy of the script with this change (BSD awk 20200816; GNU awk was
not installed, `gsub` with a literal replacement without `&` or `\` is POSIX):

- The two fixtures give the entries from the spec scenario, with `%20`.
- stderr for the same command is byte-for-byte the same as before.
- `README.md`, `tests/test directory/test_depth.md`, and `README.md` together with the
  remote sitemap.js README give byte-for-byte the same output as before.
- `shellcheck -e SC2008` reports nothing.

## Risks / Trade-offs

- [A TOC that `--insert` put into a file with several inputs with spaces changes on the
  next run] → Stated in proposal.md as an output change. Those entries were not links on
  GitHub before.
- [Other characters in a path can still break a link, for example an unbalanced `)`] →
  Not reported; a non-goal of this change.
