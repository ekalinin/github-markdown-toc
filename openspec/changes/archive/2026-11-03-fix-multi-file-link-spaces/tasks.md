# Tasks

## 1. Setup

- [x] 1.1 Create branch `fix/multi-file-link-spaces` from `master` and verify
  `git branch --show-current` prints `fix/multi-file-link-spaces`

## 2. Tests first

- [x] 2.1 Add the test `TOC for several files with a space in the path, #76` at the end of
  `tests/tests.bats`: `run gh_md_toc_no_stderr` with `tests/test\ directory/test_depth.md`
  and `tests/test\ directory/test_numbered.md`, assert success, the five entries of
  `test_depth.md` and the first entry of `test_numbered.md` from the spec scenario "Two
  local files in a directory with a space", and the last line
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`; verify it fails
  before the fix (`bats --filter "#76" tests`), with
  `* [Title one](tests/test directory/test_depth.md#title-one)` as the actual first entry

## 3. Fix

- [x] 3.1 `gh_toc_grab`: in `common_awk_script`, before `entry[count] = ...`, copy
  `gh_url` to `link_url`, run `gsub(/ /, "%20", link_url)` with a comment that refers to
  #76, and use `link_url` instead of `gh_url` in `entry[count]`; leave the warning on
  `gh_url`; verify `bats --filter "#76" tests` passes and `git diff gh-md-toc` shows only
  this change

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass
  (58 tests) and `git diff tests/tests.bats` only adds the new test
- [x] 4.2 With the script from `master` (`git show master:gh-md-toc`), compare the output
  for `README.md`, every fixture in `tests/test directory/` and the four remote pages from
  the `remote-toc` spec, each as a single input, and for `README.md` together with the
  remote sitemap.js README; verify it is byte-for-byte the same
- [x] 4.3 With the script from `master`, compare stderr of
  `gh-md-toc "tests/test directory/test_depth.md" "tests/test directory/test_numbered.md"`;
  verify it is byte-for-byte the same, with `tests/test directory/test_numbered.md: ` at
  the start
