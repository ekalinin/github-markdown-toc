# Tasks

## 1. Setup

- [x] 1.1 Create branch `fix/remote-first-heading` from `master` and verify `git branch --show-current` prints `fix/remote-first-heading`

## 2. Tests first

- [x] 2.1 Uncomment `TOC for remote README.md`, `TOC for mixed README.md (remote/local)` and `TOC for remote non-english chars (remote load), #6, #10` in `tests/tests.bats` without changing their assertions; verify `git diff tests/tests.bats` only removes the leading `# ` / `#` from those lines
- [x] 2.2 Run the suite with the unfixed script (`make test`, or `npx --yes bats@1 tests` when `bats` is not installed) and verify exactly those three tests fail and the other 11 pass

## 3. Fix

- [x] 3.1 In `gh_toc_grab` (`gh-md-toc`), change the `$grepcmd` pattern from `'<h.*class="heading-element".*</a'` to `'<h[1-6][^>]*class="heading-element".*</a'`; verify `git diff gh-md-toc` shows only that one line
- [x] 3.2 Run the suite again and verify all 14 tests pass
- [x] 3.3 Run `make lint` and verify shellcheck reports no new warnings compared to `master`

## 4. Manual checks

- [x] 4.1 Run `./gh-md-toc https://github.com/ekalinin/github-markdown-toc/blob/master/README.md` and verify the first entry is `* [gh-md-toc](#gh-md-toc)` and every entry links to `#...`
- [x] 4.2 Run `./gh-md-toc https://github.com/ekalinin/nodeenv/wiki/Who-Uses-Nodeenv` and verify the output is the same as with the script from `master`
