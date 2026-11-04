# Tasks

## 1. Setup

- [x] 1.1 Update `master` from `origin` and create branch `fix/crlf-markers` from it;
  verify `git branch --show-current` prints `fix/crlf-markers`

## 2. Tests first

- [x] 2.1 Add the five tests from design.md - Tests at the end of `tests/tests.bats`, each
  writing its file into `$BATS_TEST_TMPDIR` with `printf` as in the spec scenarios of
  `toc-markers`; verify that `bats --filter "#119" tests` fails before the fix for the
  CRLF insert, CRLF stdout, CRLF skip header and trailing whitespace tests, and passes for
  the indented markers test

## 3. Fix

- [x] 3.1 Replace the five `grep -Fxq "<!--ts-->"` / `grep -Fxq "<!--te-->"` checks in
  `gh_toc_md2html`, `gh_toc` and `gh_toc_stdout` with
  `grep -Eq '^<!--ts-->[[:space:]]*$'` / `grep -Eq '^<!--te-->[[:space:]]*$'`; verify
  `grep -c 'grep -Fxq' gh-md-toc` is `0` and the trailing whitespace and CRLF skip header
  tests pass
- [x] 3.2 In `gh_toc` (`--insert`), after the TOC file `${toc_path}` is written and
  before the `sed` that reads it, when the `<!--ts-->` line ends with `\r`, rewrite the
  file with `awk '{print $0 "\r"}'` into `${toc_path}.crlf` and move it over
  `${toc_path}`, with a comment that refers to #119; verify the CRLF insert test passes
- [x] 3.3 In `gh_toc_stdout`, do the same for `${gh_tmp_toc}`, and add
  `${gh_tmp_toc:+"$gh_tmp_toc.crlf"}` to its `trap`; verify the CRLF stdout test passes
  and `bats --filter "#119" tests` passes

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass
  (64 tests) and `git diff tests/tests.bats` only adds the new tests
- [x] 4.2 With the script from `master` (`git show master:gh-md-toc`), compare
  `--insert --no-backup --hide-footer` and `--hide-footer --stdout` on copies of
  `tests/test directory/test_stdout.md` and `README.md`, and `--skip-header README.md`;
  verify the results are byte-for-byte the same
- [x] 4.3 In `ubuntu:24.04` (GNU grep, GNU sed, mawk), with the repository mounted and
  `GH_TOC_TOKEN` passed, install `bats` and `curl` and run `bats --filter "#119" tests`;
  verify all five tests pass (4.1 already runs them with BSD grep, sed and awk, which
  bash uses on macOS: `bash -c 'command -v grep'` prints `/usr/bin/grep`)
