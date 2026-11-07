# toc-skip-no-markers Specification

## Purpose

Lets `--insert` run on many local files, such as all markdown files found by `find`, by
skipping the files without the `<!--ts-->` and `<!--te-->` markers instead of stopping
with an error.

## Requirements

### Requirement: Skip a file without markers

With `--skip-no-markers`, a local file SHALL be skipped when it has no line that counts as
the `<!--ts-->` marker or no line that counts as the `<!--te-->` marker, as defined in
`toc-markers`. A skipped file SHALL NOT be changed, no backup or TOC files SHALL be
created for it, no request SHALL be sent to the GitHub API for it, and stdout SHALL have
no TOC entries of it. For a skipped file, the program SHALL print
`<input>: Warning: no <!--ts--> or <!--te--> in the file, skipped` to stderr, where
`<input>` is the input as given on the command line, also with one input. The other
inputs SHALL be processed as before this change.

The exit code SHALL be 0 when every local file is skipped. An error of another input,
such as a GitHub API error, SHALL exit with code 1 as before this change. A local input
that is not an existing file, such as a missing path, SHALL NOT be skipped and SHALL give
the same output and exit code as before this change.

#### Scenario: Several files

- **WHEN** the user runs
  `gh-md-toc --insert --no-backup --hide-footer --skip-no-markers <dir>/a.md <dir>/b.md <dir>/c.md`,
  where `a.md` is `<!--ts-->\n<!--te-->\n\n# Page a\n`, `b.md` is `# Page b\n`, and
  `c.md` is `<!--ts-->\n<!--te-->\n\n# Page c\n`
- **THEN** `a.md` is `<!--ts-->\n* [Page a](#page-a)\n<!--te-->\n\n# Page a\n`, `c.md`
  is `<!--ts-->\n* [Page c](#page-c)\n<!--te-->\n\n# Page c\n`, `b.md` does not change,
  stdout has the lines `* [Page a](#page-a)` and `* [Page c](#page-c)` and no line
  `* [Page b](#page-b)`, stderr is
  `<dir>/b.md: Warning: no <!--ts--> or <!--te--> in the file, skipped`, and the exit
  code is 0

#### Scenario: One file with one marker

- **WHEN** the user runs `GH_TOC_TOKEN=invalid gh-md-toc --insert --skip-no-markers <dir>/b.md`,
  where `<dir>` has only `b.md`, and `b.md` is `<!--ts-->\n\n# Page b\n`
- **THEN** `b.md` does not change, `<dir>` has only `b.md`, stdout has no line
  `Parsing local markdown file requires access to github API`, stderr is
  `<dir>/b.md: Warning: no <!--ts--> or <!--te--> in the file, skipped`, and the exit
  code is 0

#### Scenario: Missing file

- **WHEN** the user runs `gh-md-toc --skip-no-markers <dir>/missing.md`, where
  `missing.md` does not exist
- **THEN** stderr has no line that ends with `in the file, skipped`, and the exit code
  is 1

### Requirement: Turns on --insert

`--skip-no-markers` SHALL turn on `--insert`, as `--no-backup` and `--hide-footer` do. A
local file with the markers and a remote URL SHALL get the same output and the same
changes as with `--insert` without `--skip-no-markers`.

`--skip-no-markers` SHALL be accepted after `--indent <NUM>`, `--depth <NUM>`,
`--numbered <TYPE>`, `--bullet <CHAR>`, `--insert`, `--no-backup` and `--hide-footer`
(when given) and before `--stdout`, `--skip-header` and the inputs.

#### Scenario: Without --insert

- **WHEN** the user runs `gh-md-toc --skip-no-markers <dir>/a.md`, where `a.md` is
  `<!--ts-->\n<!--te-->\n\n# Page a\n`
- **THEN** line 2 of `a.md` is `* [Page a](#page-a)`, stdout has the line
  `!! TOC was added into: '<dir>/a.md'`, and the exit code is 0

### Requirement: Without the option

Without `--skip-no-markers`, `--insert` on a local file without the markers SHALL print
`You don't have <!--ts--> or <!--te--> in your file...exiting` to stdout and exit with
code 1, and the inputs after that file SHALL NOT be processed, as before this change.

#### Scenario: Several files without the option

- **WHEN** the user runs
  `gh-md-toc --insert --no-backup --hide-footer <dir>/a.md <dir>/b.md <dir>/c.md`, with
  the files of the scenario "Several files"
- **THEN** line 2 of `a.md` is `* [Page a](#page-a)`, stdout has the line
  `You don't have <!--ts--> or <!--te--> in your file...exiting`, `b.md` and `c.md` do
  not change, and the exit code is 1

### Requirement: Invalid usage with --stdout

With `--skip-no-markers` and `--stdout`, the program SHALL print
`--skip-no-markers cannot be used with --stdout.` to stderr, print nothing to stdout, and
exit with code 1 before any network call.

#### Scenario: With --stdout

- **WHEN** the user runs
  `gh-md-toc --skip-no-markers --stdout "tests/test directory/test_stdout.md"`
- **THEN** stderr is `--skip-no-markers cannot be used with --stdout.`, stdout is empty,
  and the exit code is 1

### Requirement: Help lists the option

`--help` SHALL list `--skip-no-markers` in the "Options" section right after
`--hide-footer`.

#### Scenario: Help output

- **WHEN** the user runs `gh-md-toc --help`
- **THEN** the line after
  `  --hide-footer       Do not write date & author of the last TOC update. Set --insert as well. Default: false.`
  is
  `  --skip-no-markers   Skip files without <!--ts--> or <!--te-->. Set --insert as well. Default: false.`
