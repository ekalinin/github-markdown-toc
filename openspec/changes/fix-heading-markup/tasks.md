# Tasks

## 1. Setup

- [x] 1.1 Create branch `fix/heading-markup` from `master` and verify
  `git branch --show-current` prints `fix/heading-markup`

## 2. Tests first

- [x] 2.1 Add the fixture `tests/test directory/test_headingmarkup.md` with the headings
  from the spec scenario "Headings with links, an image, formatting and escaped
  characters", each followed by `Blabla...` as in `test_depth.md`; verify that
  `./gh-md-toc "tests/test directory/test_headingmarkup.md"` prints
  `   * [On <sub><sub><a href="#top">Go to Top</a></sub></sub>](#top)` (the bug)
- [x] 2.2 Add the test `TOC for headings with links and formatting, #40, #67` at the end
  of `tests/tests.bats`, asserting every entry from that spec scenario and the footer
  line; verify it fails before the fix (`bats --filter "#40, #67" tests`)
- [x] 2.3 In the #145 test change the assertion `* [<em>Title two</em>](#title-two)` to
  `* [Title two](#title-two)`, and change the same line in the TOC of
  `tests/test directory/test_setextwithformatting.md`; verify the #145 test fails before
  the fix (the run rewrites the fixture line back, it is fixed again in 4.2)

## 3. Fix

- [x] 3.1 `gh_toc_grab`: change `href_regex` to `/class="anchor"[^>]*href="[^"]+"/`, and
  in both `awkscript` branches (default and OS/390) replace the `href = ...` line with
  matching `href_regex`, keeping the matched element, and taking `href` from it with
  `match` on `/href="[^"]+"/`; verify the output for `test_headingmarkup.md` has the
  links `#on-go-to-top`, `#my-issue`, `#see-docs-here`, `#a--b`
- [x] 3.2 `gh_toc_grab`: add `gsub(/<[^>]*>/, "", text)` to `common_awk_script`; verify
  the tests from 2.2 and 2.3 pass
- [x] 3.3 Update steps 4 and 5 of the comment at the top of `gh-md-toc` to the current
  text expression with the tag removal and to the anchor taken from the
  `class="anchor"` element; verify `git diff gh-md-toc` shows only the changes from 3.1
  to 3.3

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass
  (50 tests) and `git diff tests/tests.bats` changes only the #145 assertion and adds
  the new test
- [x] 4.2 Verify `git diff "tests/test directory/test_setextwithformatting.md"` shows
  only the `Title two` line changed to `* [Title two](#title-two)`
- [x] 4.3 With the script from `master` (`git show master:gh-md-toc`), compare the output
  for `README.md`, every other fixture in `tests/test directory/` and the four remote
  pages from the `remote-toc` spec; verify it is byte-for-byte the same
