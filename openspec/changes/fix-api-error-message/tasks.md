# Tasks

## 1. Setup

- [x] 1.1 Update `master` from `origin` and create branch `fix/api-error-message` from it;
  verify `git branch --show-current` prints `fix/api-error-message`

## 2. Tests first

- [x] 2.1 Add the test "Error for local file larger than the GitHub API limit, #141" from
  design.md - Test at the end of `tests/tests.bats`; verify it fails before the fix
  (`bats --filter "#141" tests`), with no `${lines[4]}`

## 3. Fix

- [x] 3.1 `gh_toc_md2html`: in the `XXApiErrorXX` branch, take the message from `OUTPUT`
  with the `awk` from design.md and return `XXApiErrorXX ${http_code} ${message}`, with a
  comment that refers to #141; verify `git diff gh-md-toc` changes no other branch
- [x] 3.2 `gh_toc_check_api_error`: split the code from the message at the first space,
  print `Error: GitHub API request failed (HTTP <code>)` as before, and the message as the
  next line when it is not empty; verify `bats --filter "#141" tests` passes

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass
  (65 tests) and `git diff tests/tests.bats` only adds the new test
- [x] 4.2 Run the new script on the #141 wiki file (`0-IndiMail Wiki.md` from
  `https://github.com/indimail/indimail-mta.wiki.git`) and with `--stdout` on a 1 MiB file
  with `<!--ts-->` / `<!--te-->`; verify the three lines on stdout and on stderr, and exit
  code 1
- [x] 4.3 In `ubuntu:24.04` (mawk), with the repository mounted and `GH_TOC_TOKEN`
  passed, install `bats` and `curl` and run `bats --filter "#141" tests`; verify the test
  passes
