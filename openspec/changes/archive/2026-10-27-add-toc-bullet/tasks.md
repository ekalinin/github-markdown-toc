# Tasks

## 1. Tests

- [x] 1.1 Add a test in `tests/tests.bats` for `--bullet -` on
  `tests/test directory/test_depth.md`, as in the spec scenario
  "Bullet character - Local file"; verify it fails before the implementation
  (`bats --filter "<test name>" tests`)
- [x] 1.2 Add a test for `--bullet - -` with `test_depth.md` on stdin, as in the spec
  scenario "Every input - Stdin with a dash", including the number of lines (5); verify
  it fails before the implementation
- [x] 1.3 Add a test for `--numbered outline --bullet +` on
  `tests/test directory/test_numbered.md`, as in the spec scenario
  "Every input - Outline numbers"; verify it fails before the implementation
- [x] 1.4 Add tests for the spec scenarios "Unknown character" and "Ordered list":
  `assert_fail` and the message in `${lines[0]}`; verify they fail before the
  implementation
- [x] 1.5 Update `test_help`: the `--bullet` line at index 10, the `--insert`,
  `--no-backup`, `--hide-footer`, `--skip-header` lines at 11, 13, 14, 15, and 17 lines
  in total; verify `--help` and `no arguments` fail before the implementation

## 2. Implementation

- [x] 2.1 `gh_toc_grab`: take the bullet as the fifth argument, pass it to awk with
  `-v "bullet=$5"`, add `if (bullet != "") marker = bullet " "` in `common_awk_script`
  right after `marker = "* "` and before the `list` line, and describe `$5` in the
  comment above the function; verify `make lint` passes and the existing tests still
  pass
- [x] 2.2 `gh_toc_app`: add `local bullet=""`, a `--bullet` check right after the
  `--numbered` check, and the two checks from design.md (the bullet `case` with a quoted
  `"*"`, and the check against `--numbered list`); pass `$bullet` to `gh_toc_grab` in the
  stdin branch and to `gh_toc` as the 10th parameter. `gh_toc`: take
  `local bullet=${10}` and pass it to both `gh_toc_grab` calls; verify the tests from
  1.1 to 1.4 pass
- [x] 2.3 `show_help`: add
  `  --bullet <CHAR>     Bullet of TOC entries: *, - or +. Default: *.`
  right after the `--numbered` line; verify the tests from 1.5 pass
- [x] 2.4 Check the inputs not covered by the tests: run
  `./gh-md-toc --bullet - https://github.com/ekalinin/github-markdown-toc/blob/master/README.md`,
  `./gh-md-toc --bullet + "tests/test directory/test_depth.md" "tests/test directory/test_noh1.md"`,
  and `./gh-md-toc --bullet - --insert --no-backup <copy>` on a copy of `README.md` in a
  temporary directory; verify each exits with code 0 and every entry starts with the
  chosen bullet after its indent

## 3. Documentation

- [x] 3.1 README, section "Local files": after the `--numbered outline` example, add a
  sentence about `--bullet <CHAR>` with the characters `*`, `-` and `+`, and the example
  `./gh-md-toc --bullet - ~/projects/Dockerfile.vim/README.md` with the output of a real
  run on the current `ekalinin/Dockerfile.vim` README; add no new heading; verify the
  README TOC tests (`TOC for local README.md`, `TOC for local README.md with skip headers`,
  `TOC for markdown from stdin`) still pass

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass
