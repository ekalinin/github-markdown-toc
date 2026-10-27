# Proposal

## Why

`gh-md-toc` always starts bullet entries of the TOC with `*`, and there is no option to
use a dash instead (#71, open since 2018, with a second request in its comments). Today
the only way is to edit the `* ` string inside the script.

## What Changes

- New option `--bullet <CHAR>`, where `CHAR` is `*`, `-` or `+` (the three bullet
  markers of CommonMark). Every entry that starts with `*` today starts with `CHAR`
  instead: `- [Title](#title)`. The default stays `*`, so the output without the option
  does not change.
- With `--numbered outline`, the entries use the chosen bullet:
  `- [2.1. Section](#section)`.
- The option applies to every input: stdin, local file, remote URL, several inputs, and
  `--insert`.
- `--bullet` is parsed in the existing fixed order of options, right after `--numbered`
  and before `-`. `--bullet - -` reads stdin with dash bullets.
- Errors, with exit code 1 and no TOC: an unknown `CHAR`, and `--bullet` together with
  `--numbered list` (an ordered list has no bullet).
- `--help`: a new line for `--bullet` right after `--numbered`.
- README: a sentence and an example in the "Local files" section, after the
  `--numbered outline` example, without a new heading.
- Tests: tests for a local file, stdin, `--bullet +` with `--numbered outline`, both
  errors, and an updated `test_help`.

Non-goals:

- Bullet characters other than `*`, `-` and `+`.
- A different bullet per level.
- A change of the default bullet.
- The `--bullet=CHAR` syntax and a rewrite of the argument parser.
- A version bump.

## Capabilities

### New Capabilities

- `toc-bullet`: the bullet character of TOC entries (`*`, `-` or `+`), for every input.

### Modified Capabilities

- `toc-numbered`: "Hierarchical numbers" states the form `* [<number> <heading text>](<link>)`;
  with `--bullet` the entry starts with the chosen bullet.

## Impact

- `gh-md-toc`: `gh_toc_app` (parse and check `--bullet`, pass it on), `gh_toc` (new
  parameter), `gh_toc_grab` (the marker in the awk script shared by the default and
  OS/390 branches), `show_help`.
- `tests/tests.bats`: new tests and an updated `test_help` (17 lines instead of 16).
  The tests for a local file and stdin call the GitHub API, like the existing ones; the
  error tests do not. The existing fixtures are reused.
- `README.md`: an example only, no new heading, so the README TOC asserted in
  `tests/tests.bats` does not change.
- `openspec/specs/remote-toc` and `openspec/specs/toc-depth` describe the output without
  `--bullet`; their requirements do not change. `openspec/specs/landing` describes the
  TOC of the landing page, not the options, and is not affected.
- Order of archiving: the change `fix-relative-toc-indent` (all tasks done, merged in
  #180, not archived yet) also modifies "Hierarchical numbers" in `toc-numbered`. The
  delta of this change is written on top of its text (`(level - top) * indent`), so
  `fix-relative-toc-indent` must be archived first.
