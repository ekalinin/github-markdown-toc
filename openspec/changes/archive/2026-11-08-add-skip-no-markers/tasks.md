# Tasks

## 1. Tests

- [x] 1.1 Add the test "Insert into several files skips a file without markers, #110" in
  `tests/tests.bats`, as in the spec scenario "Skip a file without markers - Several
  files": `a.md`, `b.md`, `c.md` in `$BATS_TEST_TMPDIR`, `run_to_files`, the files
  compared with `cmp`, stdout with `grep -Fxc`, `err.txt` with `assert_equal`; verify it
  fails before the implementation (`bats --filter "<test name>" tests`)
- [x] 1.2 Add the test "Skip a file with one marker without a GitHub API request, #110",
  as in the spec scenario "One file with one marker": `b.md` in its own directory under
  `$BATS_TEST_TMPDIR`, `GH_TOC_TOKEN=invalid`, `ls` of the directory is `b.md`, no
  `Parsing local markdown file requires access to github API` in `out.md`; verify it
  fails before the implementation
- [x] 1.3 Add the test "No skip for a missing file, #110", as in the spec scenario
  "Missing file": `assert_fail` and no `in the file, skipped` in `err.txt`; verify it
  passes before the implementation
- [x] 1.4 Add the test "--skip-no-markers turns on --insert, #110", as in the spec
  scenario "Without --insert": line 2 of `a.md` and the `!! TOC was added into` line in
  `out.md`; verify it fails before the implementation
- [x] 1.5 Add the test "Insert into several files stops at a file without markers, #110",
  as in the spec scenario "Several files without the option": line 2 of `a.md`, the
  `You don't have ...` line in `out.md`, `b.md` and `c.md` compared with `cmp`,
  `assert_fail`; verify it passes before the implementation
- [x] 1.6 Add the test "Error for --skip-no-markers with --stdout, #110", as in the spec
  scenario "With --stdout": `assert_fail`, `err.txt` is the message, `out.md` is empty;
  verify it fails before the implementation
- [x] 1.7 Update `test_help`: the `--skip-no-markers` line at index 15, the `--stdout`
  and `--skip-header` lines at 16 and 17, and 19 lines in total; verify `--help` and
  `no arguments` fail before the implementation

## 2. Implementation

- [x] 2.1 `gh_toc_app`: add `local skip_no_markers=""` next to `local to_stdout=""`, the
  `--skip-no-markers` check right after `--hide-footer` (sets `need_replace="yes"` and
  `skip_no_markers="yes"`), and pass `"$skip_no_markers"` to `gh_toc` as the 11th
  parameter. `gh_toc`: take `local skip_no_markers=${11}`, and right after the check for
  an empty input add the check from design.md (local input, `[ -f "$gh_src" ]`, the two
  `grep -Eq` of `gh_toc_stdout`, the warning to stderr, `return`); verify `make lint`
  passes, the tests from 1.1, 1.2 and 1.4 pass, and the tests from 1.3 and 1.5 still pass
- [x] 2.2 `gh_toc_app`, the `--stdout` branch: before the check of the inputs, print
  `--skip-no-markers cannot be used with --stdout.` to stderr and `exit 1` when
  `skip_no_markers` is `yes`; verify the test from 1.6 passes
- [x] 2.3 `show_help`: add
  `  --skip-no-markers   Skip files without <!--ts--> or <!--te-->. Set --insert as well. Default: false.`
  right after the `--hide-footer` line; verify the tests from 1.7 pass
- [x] 2.4 Check the cases not covered by the tests: in a temporary directory with
  `a.md` and `sub/c.md` (with markers) and `b.md` (without), run the README example
  `find . -name '*.md' -exec <repo>/gh-md-toc --insert --no-backup --hide-footer --skip-no-markers {} +`;
  verify `a.md` and `sub/c.md` get their TOC with `#<anchor>` links, `b.md` does not
  change, stderr is the warning for `./b.md`, and the exit code is 0. Run
  `./gh-md-toc --skip-no-markers https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md`;
  verify the TOC and `!! '<url>' is not a local file` are printed and the exit code is 0

## 3. Documentation

- [x] 3.1 README, section "Auto insert and update TOC": after the paragraph "Next time
  when your file will be changed just repeat the command ...", add a sentence about
  `--skip-no-markers` and the `find` example from design.md; add no new heading; verify
  the README TOC tests (`TOC for local README.md`, `TOC for local README.md with skip
  headers`, `TOC for markdown from stdin`) still pass

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass
