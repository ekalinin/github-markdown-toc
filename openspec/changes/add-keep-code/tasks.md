# Tasks

## 1. Tests

- [x] 1.1 Add the fixture `tests/test directory/test_keepcode.md` with the headings of the
  spec scenario "Inline code in backticks - Headings with inline code", separated by
  empty lines; verify with the markdown API that no heading has a line break right after
  the heading tag (#201)
- [x] 1.2 Add the test "TOC with inline code without --keep-code for local file, #153"
  in `tests/tests.bats`, as in the spec scenario "Headings with inline code without the
  option": every entry and the footer; verify it passes before the implementation
  (`bats --filter "<test name>" tests`)
- [x] 1.3 Add the test "TOC with inline code in backticks for local file, #153", as in
  the spec scenario "Headings with inline code": every entry and the footer; verify it
  fails before the implementation
- [x] 1.4 Add the test "TOC with inline code in backticks for markdown from stdin, #153",
  as in the spec scenario "Stdin with a bullet": `cat` of `test_backquote.md` into
  `--bullet - --keep-code -`, the 5 lines and `${#lines[@]}`; verify it fails before the
  implementation
- [x] 1.5 Add the test "TOC with inline code in backticks for remote file, #153", as in
  the spec scenario "Remote URL": the 5 entries with `*`; verify it fails before the
  implementation
- [x] 1.6 Add the test "Whole file with inline code in backticks to stdout, #153", as in
  the spec scenario "Whole file to stdout": `a.md` in `$BATS_TEST_TMPDIR` written with
  `printf`, `run_to_files`, stdout and `a.md` compared with `cmp`; verify it fails before
  the implementation
- [x] 1.7 Update `test_help`: the `--keep-code` line at index 11, the `--insert`,
  `--no-backup`, `--hide-footer`, `--skip-no-markers`, `--stdout` and `--skip-header`
  lines at 12, 14, 15, 16, 17 and 18, and 20 lines in total; verify `--help` and
  `no arguments` fail before the implementation

## 2. Implementation

- [x] 2.1 `gh_toc_grab`: take `$7` (document it in the comment above the function), pass
  it to awk as `-v "keep_code=$7"`, skip the `<code>` `sed` step when it is `yes`, and
  add the code span loop and `text = out text` to `common_awk_script` as in design.md;
  verify `make lint` passes and the test from 1.2 still passes
- [x] 2.2 `gh_toc_app`: add `local keep_code=""` next to `local bullet=""` and the
  `--keep-code` check right after `--bullet`; pass `"" "$keep_code"` to `gh_toc_grab` in
  the stdin branch, `"$keep_code"` to `gh_toc_stdout` as the 8th parameter and to
  `gh_toc` as the 12th. `gh_toc`: take `local keep_code=${12}`, pass `"" "$keep_code"`
  in the remote call and `"$keep_code"` after `"$need_replace"` in the local call.
  `gh_toc_stdout`: take `local keep_code=$8`, pass `"" "$keep_code"`; verify `make lint`
  passes and the tests from 1.3 to 1.6 pass
- [x] 2.3 `show_help`: add
  `  --keep-code         Keep inline code of headings in backticks. Default: false.`
  right after the `--bullet` line; verify the tests from 1.7 pass
- [x] 2.4 Check the cases not covered by the tests: render the TOC entries of
  `--keep-code` on the fixture with the markdown API and verify every `<code>` content
  is the same as in the headings; run `--keep-code --insert --no-backup --hide-footer` on
  a copy of the file from 1.6 and verify the TOC in it is the same as in the output of
  1.6; run `--keep-code` with several inputs (the fixture and `test_backquote.md`) and
  verify the entries have the backticks and the link prefix

## 3. Documentation

- [x] 3.1 README, section "Local files": after the `--bullet` example, add the sentence
  and the example from design.md; add no new heading; verify the example output with
  `./gh-md-toc`, and verify the README TOC tests (`TOC for local README.md`, `TOC for
  local README.md with skip headers`, `TOC for markdown from stdin`) still pass

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass
- [x] 4.2 Run `./gh-md-toc --keep-code` and `./gh-md-toc` on the fixture in a Debian
  container with mawk and with GNU awk (the files passed in with `tar` on stdin); verify
  both outputs are the same as on macOS
