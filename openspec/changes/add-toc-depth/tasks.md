# Tasks

## 1. Tests

- [x] 1.1 Add the fixture `tests/test directory/test_depth.md` with the headings
  `# Title one`, `## Section`, `### Subsection`, `#### Deep`, `# Title two`; verify that
  `./gh-md-toc "tests/test directory/test_depth.md"` prints the five entries from the
  spec scenario "Without the option"
- [x] 1.2 Add a test in `tests/tests.bats` for `--depth 2` on the fixture, as in the spec
  scenario "Local file"; verify it fails before the implementation
  (`bats --filter "<test name>" tests`)
- [x] 1.3 Add a test for `--depth 1 -` with the fixture on stdin, as in the spec scenario
  "Stdin"; verify it fails before the implementation
- [x] 1.4 Update `test_help`: the `--depth` line at index 8, the `--insert`,
  `--no-backup`, `--hide-footer`, `--skip-header` lines at 9, 11, 12, 13, and 15 lines
  in total; verify `--help` and `no arguments` fail before the implementation

## 2. Implementation

- [x] 2.1 `gh_toc_grab`: take the depth as the third argument, pass it to awk with
  `-v "depth=$3"`, add `if (depth+0 > 0 && level+0 > depth+0) next` at the start of
  `common_awk_script`, and describe `$3` in the comment above the function; verify
  `make lint` passes and the existing tests still pass
- [x] 2.2 `gh_toc_app`: add `local depth=0` and a `--depth` check right after the
  `--indent` check; pass `$depth` to `gh_toc_grab` in the stdin branch and to `gh_toc`
  as the 8th parameter. `gh_toc`: take `local depth=$8` and pass it to both
  `gh_toc_grab` calls; verify the tests from 1.2 and 1.3 pass
- [x] 2.3 `show_help`: add
  `  --depth <NUM>       Max heading level to include into TOC. Default: 0 (all levels).`
  right after the `--indent` line; verify the tests from 1.4 pass
- [x] 2.4 Check the spec scenario "Zero depth": verify the output of
  `./gh-md-toc --depth 0 "tests/test directory/test_depth.md"` is the same as without
  the option

## 3. Documentation

- [x] 3.1 README, section "Local files": after the existing example, add a sentence
  about `--depth` and the example `./gh-md-toc --depth 1 ~/projects/Dockerfile.vim/README.md`
  with the output of a real run on the current `ekalinin/Dockerfile.vim` README; add no
  new heading; verify the README TOC tests (`TOC for local README.md`,
  `TOC for local README.md with skip headers`, `TOC for markdown from stdin`) still pass

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass
