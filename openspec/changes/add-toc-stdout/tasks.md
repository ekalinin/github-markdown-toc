# Tasks

## 1. Fixture and tests

- [x] 1.1 Create `tests/test directory/test_stdout.md` with
  `printf '# Title\n\n<!--ts-->\n* [Old entry](#old-entry)\n<!--te-->\n\n    # indented code, not a heading\n\n## Section\n\nText without a newline at the end'`;
  verify `tail -c 1` prints `d` and `grep -Fxc` finds `<!--ts-->` and `<!--te-->` once
  each
- [x] 1.2 Add to `tests/tests.bats` a helper that prints the expected bytes of the spec
  scenario "Whole document with the new TOC - Local file" with `printf`, and a test for
  that scenario: run the command with `bash -c`, stdout into a file in
  `$BATS_TEST_TMPDIR`, compare with `cmp`; add a comment that the fixture has no newline at
  the end on purpose; verify it fails before the implementation
  (`bats --filter "<test name>" tests`)
- [x] 1.3 Add a test for the scenario "Footer": lines 6 to 10 of stdout are ``,
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`, a line starting
  with `<!-- Added by: `, `` and `<!--te-->` (`sed -n` on the stdout file, `run` skips
  empty lines); verify it fails before the implementation
- [x] 1.4 Add a test for the scenario "Same content as --insert": copy the fixture into
  `$BATS_TEST_TMPDIR`, run `--insert --no-backup --hide-footer` on the copy, run
  `--hide-footer --stdout` on the fixture, `cmp` the copy with stdout; verify it fails
  before the implementation
- [x] 1.5 Add a test for the scenario "Insert options together with --stdout": `cksum` of
  the fixture and `ls -A "tests/test directory"` before and after the run are the same,
  and stdout matches the helper from 1.2 with `cmp`; verify it fails before the
  implementation
- [x] 1.6 Add a test for the scenario "Document from stdin - Stdin" with the helper from
  1.2 and `cmp`; verify it fails before the implementation
- [x] 1.7 Add tests for the scenarios "Bullet" and "Skip header" with `run` and
  `${lines[...]}` between `<!--ts-->` and `<!--te-->`; verify they fail before the
  implementation
- [x] 1.8 Add tests for the scenarios "Two inputs", "URL", "No markers" and "Invalid
  GitHub token": with `bash -c`, stdout and stderr into separate files, exit code 1, an
  empty stdout file, and the message in the stderr file (`grep -Fx` for the token test);
  verify they fail before the implementation
- [x] 1.9 Add tests for the temporary files: with `TMPDIR` set to an empty directory in
  `$BATS_TEST_TMPDIR`, the directory is empty after
  `cat <fixture> | gh-md-toc --hide-footer --stdout -` (exit code 0) and after the same
  run with `GH_TOC_TOKEN=invalid` (exit code 1, the 401 message in stderr); verify both
  fail before the implementation (today `--stdout` is taken as an input, so the exit
  code and the message differ)
- [x] 1.10 Add tests for the scenarios "Indented code line" and "Last heading without a
  newline" of "Stdin read as is", with `run` and the number of lines (2); verify they
  fail before the implementation (today the first one has 3 entries and the second one
  is empty)
- [x] 1.11 Update `test_help`: the `--stdout` line at index 15, `--skip-header` at 16,
  and 18 lines in total; verify `--help` and `no arguments` fail before the
  implementation

## 2. Implementation

- [x] 2.1 Move the temporary file code of the `-` branch of `gh_toc_app` into
  `gh_toc_mktemp` (prints the path of a new empty file; `$TMPDIR` or `/tmp`, created when
  missing; `mktemp`; on OS/390 the name `tmp.<timestamp>.$$.$RANDOM`). In the `-` branch,
  use it and replace the `while read -r` loop with `cat > "$gh_tmp_md"`; verify
  `make lint` passes, the tests from 1.10 pass and the existing stdin tests still pass
- [x] 2.2 Add `gh_toc_stdout` as in design.md (`trap` on the global `gh_tmp_stdin` and
  `gh_tmp_toc`, the local `gh_src`, the copy of stdin for `-`, the markers check to
  stderr, `gh_toc_md2html`, `gh_toc_check_api_error "$rawhtml" >&2`, `gh_toc_grab` with
  an empty URL, the TOC block with the `--insert` `echo` commands, the sed pipeline), with
  a comment above it in the style of the other functions; verify `make lint` passes
- [x] 2.3 `gh_toc_app`: add `local to_stdout=""`, the `--stdout` check right after
  `--hide-footer`, and right after `--skip-header` the branch from design.md (the input
  check to stderr, the call of `gh_toc_stdout`, `return`); verify the tests from 1.2 to
  1.9 pass and the existing `--insert` tests (#136, #145) still pass
- [x] 2.4 `show_help`: add
  `  --stdout            Print the whole file with the new TOC to stdout. The file is not changed. Default: false.`
  right after the `--hide-footer` line; verify the tests from 1.11 pass
- [x] 2.5 Check the cases not covered by the tests: `--numbered outline --stdout` and
  `--depth 1 --stdout` on the fixture (exit code 0, the entries between the markers), and
  `curl -s https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/README.md | ./gh-md-toc --stdout -`
  (exit code 0, and the lines outside the markers are the same as in the input: compare
  both with `sed '/<!--ts-->/,/<!--te-->/d'`)

## 3. Documentation

- [x] 3.1 README, section "Auto insert and update TOC": after the paragraph "Next time
  when your file will be changed...", add a paragraph about `--stdout` (the whole file
  with the new TOC on stdout, the file is not changed, no backup files, one local file
  or `-`, works with `--hide-footer` and `--skip-header`, do not redirect into the same
  file, use `--insert` for that) and the examples
  `./gh-md-toc --stdout README.test.md > README.new.md` and
  `curl -s <raw-url> | ./gh-md-toc --stdout - > README.md`; add no new heading; verify
  the README TOC tests (`TOC for local README.md`, `TOC for local README.md with skip
  headers`, `TOC for markdown from stdin`) still pass

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass
