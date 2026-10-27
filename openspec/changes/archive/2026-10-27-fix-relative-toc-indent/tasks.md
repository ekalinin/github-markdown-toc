# Tasks

## 1. Setup

- [x] 1.1 Create branch `fix/relative-toc-indent` from `master` and verify
  `git branch --show-current` prints `fix/relative-toc-indent`

## 2. Tests first

- [x] 2.1 Add the fixture `tests/test directory/test_noh1.md` with the headings
  `## Section one`, `### Subsection`, `## Section two`, each followed by `Blabla...` as
  in `test_depth.md`; verify that `./gh-md-toc "tests/test directory/test_noh1.md"`
  prints the three entries indented by 3, 6 and 3 spaces (the bug)
- [x] 2.2 Add a test in `tests/tests.bats` for the local file, as in the spec scenario
  "Local file without a `#` heading", including the footer line; verify it fails before
  the fix (`bats --filter "<test name>" tests`)
- [x] 2.3 Add a test for `--indent 4 -` with the fixture on stdin, as in the spec
  scenario "Stdin with an indent of 4", including the number of lines; verify it fails
  before the fix
- [x] 2.4 Add a test for `--depth 2 -` with the fixture on stdin, as in the `toc-depth`
  spec scenario "Document without a `#` heading", including the number of lines; verify
  it fails before the fix

## 3. Fix

- [x] 3.1 `gh_toc_grab`: in `common_awk_script`, replace the final `print` with storing
  the entry without the indent in `entry[count]`, its level in `entry_level[count]`, and
  updating `min_level`; add a `common_awk_end` variable with an `END` block that prints
  every entry with `sprintf("%*s", (entry_level[i] - min_level) * '"$2"', "")` in front,
  and append it to both `awkscript` branches (default and OS/390); verify `make lint`
  passes and the tests from 2.2 to 2.4 pass
- [x] 3.2 Update the comment at the top of `gh-md-toc` (step 3.2,
  `sprintf("%*s", (level-1)*'"$nb_spaces"', "")`) to the new formula; verify
  `git diff gh-md-toc` shows only the changes from 3.1 and 3.2

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass and
  the existing assertions are not changed (`git diff tests/tests.bats` only adds lines)
- [x] 4.2 Run the spec scenario "Several inputs" and verify the `test_noh1.md` entries
  start with no indent
- [x] 4.3 Run the three cases from proposal.md - Why (`###`/`####` with the default
  indent, the same with `--insert`, `##`/`###` with `--indent 4`) and render each output
  with the GitHub markdown API; verify each one is rendered as `<ul>`, not
  `<pre><code>`
