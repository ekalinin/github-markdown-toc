# Tasks

## 1. Setup

- [x] 1.1 Update `master` from `origin` and create branch `fix/multi-file-insert-prefix`
  from it; verify `git branch --show-current` prints `fix/multi-file-insert-prefix` and
  `openspec/specs/toc-multiple-inputs/spec.md` exists (it came with #191)

## 2. Tests first

- [x] 2.1 Add the test `Insert into several files links to the anchor only, #113` at the
  end of `tests/tests.bats`: write `a.md` and `b.md` into `$BATS_TEST_TMPDIR` with
  `printf` as in the spec scenario "Two local files and a remote URL", run
  `run_to_files --insert --no-backup --hide-footer` with both files and
  `https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md`,
  assert success, lines 2 and 3 of each file, the entries of both files and
  `* [sitemap.js](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#sitemapjs)`
  in `out.md` with `grep -Fx`, and `err.txt` equal to
  `$BATS_TEST_TMPDIR/b.md: Warning: heading 'Skipped' (level 3) skips a level after 'Title' (level 1), see https://github.com/ekalinin/github-markdown-toc/issues/75`;
  verify it fails before the fix (`bats --filter "#113" tests`), with
  `* [Page a]($BATS_TEST_TMPDIR/a.md#page-a)` as the actual line 2 of `a.md`

## 3. Fix

- [x] 3.1 `gh_toc_grab`: add `$6` to the comment above it, pass `-v "need_replace=$6"` to
  awk, and in `common_awk_script` change `link_url = gh_url` to
  `link_url = (need_replace == "yes" ? "" : gh_url)` with a comment that refers to #113;
  leave the warning on `gh_url`; verify `git diff gh-md-toc` shows no other change in
  `gh_toc_grab`
- [x] 3.2 `gh_toc`: in the local branch, pass `"$need_replace"` as the sixth argument of
  `gh_toc_grab`; leave the remote branch, `gh_toc_stdout` and stdin as they are; verify
  `bats --filter "#113" tests` passes

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass
  (59 tests) and `git diff tests/tests.bats` only adds the new test
- [x] 4.2 With the script from `master` (`git show master:gh-md-toc`), compare stdout and
  stderr without `--insert` for `README.md`, every fixture in `tests/test directory/`,
  `"tests/test directory/test_depth.md" "tests/test directory/test_numbered.md"`, and
  `README.md` together with the remote sitemap.js README; verify they are byte-for-byte
  the same
- [x] 4.3 With the script from `master`, run `--insert --no-backup --hide-footer` on a copy
  of `tests/test directory/test_stdout.md` as the only input; verify the file is
  byte-for-byte the same as with the new script
