# Tasks

## 1. Tests

- [x] 1.1 Add the fixture `tests/test directory/test_numbered.md` with the headings
  `# Title one`, `## Section`, `### Subsection`, `## Other section`, `# Title two`,
  `### Skipped`, `## After skip`, each followed by `Blabla...` as in `test_depth.md`;
  verify that `./gh-md-toc "tests/test directory/test_numbered.md"` prints the seven
  entries from the spec scenario "Without the option"
- [x] 1.2 Add a test in `tests/tests.bats` for `--numbered list` on the fixture, as in
  the spec scenario "Ordered list - Local file"; verify it fails before the
  implementation (`bats --filter "<test name>" tests`)
- [x] 1.3 Add a test for `--numbered outline` on the fixture, as in the spec scenario
  "Hierarchical numbers - Local file"; verify it fails before the implementation
- [x] 1.4 Add a test for `--depth 2 --numbered outline -` with the fixture on stdin, as
  in the spec scenario "Stdin with depth", including the number of lines; verify it
  fails before the implementation
- [x] 1.5 Add tests for the spec scenarios "Unknown type" and "Indent too small for a
  list": `assert_fail` and the message in `${lines[0]}`; verify they fail before the
  implementation
- [x] 1.6 Update `test_help`: the `--numbered` line at index 9, the `--insert`,
  `--no-backup`, `--hide-footer`, `--skip-header` lines at 10, 12, 13, 14, and 16 lines
  in total; verify `--help` and `no arguments` fail before the implementation

## 2. Implementation

- [x] 2.1 `gh_toc_grab`: take the type as the fourth argument, pass it to awk with
  `-v "numbered=$4"`, add the stack code from design.md after the `--depth` filter in
  `common_awk_script`, make the final print pick the marker and the text prefix by
  `numbered`, and describe `$4` in the comment above the function; verify `make lint`
  passes and the existing tests still pass
- [x] 2.2 `gh_toc_app`: add `local numbered=""`, a `--numbered` check right after the
  `--depth` check, and the two checks from design.md before the `-` branch; pass
  `$numbered` to `gh_toc_grab` in the stdin branch and to `gh_toc` as the 9th parameter.
  `gh_toc`: take `local numbered=$9` and pass it to both `gh_toc_grab` calls; verify the
  tests from 1.2 to 1.5 pass
- [x] 2.3 `show_help`: add
  `  --numbered <TYPE>   Number TOC entries: list (ordered list) or outline (1.1. in text). Default: none.`
  right after the `--depth` line; verify the tests from 1.6 pass
- [x] 2.4 Check the spec scenario "Small indent with outline", and run
  `./gh-md-toc --numbered outline https://github.com/ekalinin/github-markdown-toc/blob/master/README.md`;
  verify both print a numbered TOC and exit with code 0

## 3. Documentation

- [x] 3.1 README, section "Local files": after the `--depth` example, add a sentence
  about `--numbered <TYPE>` with the types `list` and `outline`, and the examples
  `./gh-md-toc --numbered list ~/projects/Dockerfile.vim/README.md` and
  `./gh-md-toc --numbered outline ~/projects/Dockerfile.vim/README.md` with the output
  of real runs on the current `ekalinin/Dockerfile.vim` README; add no new heading;
  verify the README TOC tests (`TOC for local README.md`,
  `TOC for local README.md with skip headers`, `TOC for markdown from stdin`) still pass

## 4. Verification

- [x] 4.1 Run `make lint` and `make test` with `GH_TOC_TOKEN` set; verify both pass
