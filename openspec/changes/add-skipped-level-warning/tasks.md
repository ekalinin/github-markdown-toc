# Tasks

## 1. Setup

- [x] 1.1 Create branch `feat/skipped-level-warning` from `master` and verify
  `git branch --show-current` prints `feat/skipped-level-warning`

## 2. Tests first

- [x] 2.1 In `tests/tests.bats`, add a helper next to `run_to_files` that runs
  `gh-md-toc` with `2>/dev/null`, with a comment why (bats `run` merges stderr into
  `lines`), and use it in the `run` line of `TOC as ordered list for local file, #26`,
  `TOC with outline numbers for local file, #26` and
  `TOC with plus bullets and outline numbers for local file, #71`; verify the three
  tests pass and `git diff tests/tests.bats` shows only the helper and the three `run`
  lines
- [x] 2.2 Add a test for `test_numbered.md` with `run_to_files`, as in the spec scenarios
  "Warning for a skipped level - Local file" and "TOC does not change - Local file":
  stderr is exactly the warning line, the TOC entries and the footer line on stdout are
  the ones from the scenario, the exit code is 0; verify it fails before the
  implementation (`bats --filter "#75" tests`)
- [x] 2.3 Add a test for the `printf` input on stdin, as in the spec scenario "Entries
  without a parent and two skipped levels": stderr is exactly the two warning lines in
  this order; verify it fails before the implementation
- [x] 2.4 Add a test for `--insert --no-backup --hide-footer` on a file written with
  `printf` into `$BATS_TEST_TMPDIR`, as in the spec scenario "Insert into a file": the
  lines between `<!--ts-->` and `<!--te-->` in the file, no `Warning` in the file, stderr
  is exactly the warning line; verify it fails before the implementation only on stderr
- [x] 2.5 Add a test for `--hide-footer --stdout -` with the `printf` input, as in the
  spec scenario "Whole file to stdout": stdout compared with `cmp` against the expected
  lines, stderr is exactly the warning line; verify it fails before the implementation
  only on stderr
- [x] 2.6 Add a test for several inputs, as in the spec scenario "Several inputs": stderr
  is exactly the warning line with the `tests/test directory/test_numbered.md: ` prefix;
  verify it fails before the implementation
- [x] 2.7 Add tests for the spec scenarios "Stdin with depth" and "Consecutive levels":
  stderr is empty and the exit code is 0; verify they pass before and after the
  implementation

## 3. Implementation

- [x] 3.1 `gh_toc_grab`, `common_awk_script`: between the `while` that pops the stack and
  the push, add the check `top > 0 && level+0 > lvls[top] + 1` that prints the message
  from the spec to `"cat 1>&2"`, with the quotes written as `\047`, the
  `(gh_url != "" ? gh_url ": " : "")` prefix and a comment that refers to #75; add
  `txts[top] = text` to the push; verify `make lint` passes and the tests from 2.2 to
  2.6 pass

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass and
  `git diff tests/tests.bats` changes only the three `run` lines from 2.1 and adds the
  helper and the new tests
- [x] 4.2 With the script from `master` (`git show master:gh-md-toc`), compare stdout for
  `README.md`, every fixture in `tests/test directory/`, the `printf` inputs from the
  spec and the remote pages from the `remote-toc` spec; verify stdout is byte-for-byte
  the same, and stderr of the new script is empty for every input except
  `test_numbered.md` and the `printf` inputs
