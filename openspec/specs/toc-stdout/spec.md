# toc-stdout Specification

## Purpose

Lets the user get the whole document with a refreshed TOC on stdout, without changing the
source file, for a local file or a document read from stdin.

## Requirements

### Requirement: Whole document with the new TOC

With `--stdout` and one local file, the program SHALL print to stdout the content that
`--insert` with the same options would write into the file: the lines between
`<!--ts-->` and `<!--te-->` are replaced with the new TOC, followed by an empty line,
`<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`,
`<!-- Added by: <user>, at: <date> -->` and an empty line. All the other lines SHALL be
printed unchanged, including a last line without a newline. The TOC links SHALL be
`#<anchor>`, without the file name.

Nothing else SHALL be printed to stdout: no `Table of Contents` header, no status lines,
no `<!-- Created by ... -->` line after the document. The exit code SHALL be 0.

#### Scenario: Local file

- **WHEN** the user runs
  `gh-md-toc --hide-footer --stdout "tests/test directory/test_stdout.md"`, where the
  file has the lines `# Title`, ``, `<!--ts-->`, `* [Old entry](#old-entry)`,
  `<!--te-->`, ``, `    # indented code, not a heading`, ``, `## Section`, ``, and
  `Text without a newline at the end` without a newline
- **THEN** stdout is `# Title`, ``, `<!--ts-->`, `* [Title](#title)`,
  `   * [Section](#section)`, `<!--te-->`, ``, `    # indented code, not a heading`, ``,
  `## Section`, ``, and `Text without a newline at the end` without a newline, and the
  exit code is 0

#### Scenario: Footer

- **WHEN** the user runs `gh-md-toc --stdout "tests/test directory/test_stdout.md"`
- **THEN** the lines between `   * [Section](#section)` and `<!--te-->` are ``,
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`,
  `<!-- Added by: <user>, at: <date> -->` and ``

#### Scenario: Same content as --insert

- **WHEN** the user runs `gh-md-toc --insert --no-backup --hide-footer <copy>` on a copy
  of `tests/test directory/test_stdout.md`, and
  `gh-md-toc --hide-footer --stdout "tests/test directory/test_stdout.md"`
- **THEN** stdout of the second run is byte-for-byte the content of the copy after the
  first run

### Requirement: Source is not changed

With `--stdout`, the program SHALL NOT change the input file and SHALL NOT leave new files
next to it, such as `.orig.<date>` or `.toc.<date>`, also when `--insert` or `--no-backup`
is given. The temporary files the program creates SHALL be removed before it exits, also
when it exits with an error.

#### Scenario: Insert options together with --stdout

- **WHEN** the user runs
  `gh-md-toc --insert --no-backup --hide-footer --stdout "tests/test directory/test_stdout.md"`
- **THEN** the file `tests/test directory/test_stdout.md` has the same bytes as before the
  run, `tests/test directory/` has no new files, and stdout is the same as in the scenario
  "Whole document with the new TOC - Local file"

### Requirement: Document from stdin

With `--stdout -`, the program SHALL read the document from stdin and print it as for a
local file with the same content.

#### Scenario: Stdin

- **WHEN** the user runs
  `cat "tests/test directory/test_stdout.md" | gh-md-toc --hide-footer --stdout -`
- **THEN** stdout is the same as in the scenario
  "Whole document with the new TOC - Local file", and the exit code is 0

### Requirement: Options with --stdout

`--indent <NUM>`, `--depth <NUM>`, `--numbered <TYPE>` and `--bullet <CHAR>` SHALL change
the TOC printed by `--stdout` in the same way as with `--insert`. `--hide-footer` SHALL
leave out the empty line, the two footer lines and the empty line after the TOC.
`--skip-header` SHALL leave out of the TOC the headings above `<!--te-->`, as with
`--insert`.

`--stdout` SHALL be accepted after `--indent <NUM>`, `--depth <NUM>`, `--numbered <TYPE>`,
`--bullet <CHAR>`, `--insert`, `--no-backup` and `--hide-footer` (when given) and before
`--skip-header` and the input.

#### Scenario: Bullet

- **WHEN** the user runs
  `gh-md-toc --bullet - --hide-footer --stdout "tests/test directory/test_stdout.md"`
- **THEN** the lines between `<!--ts-->` and `<!--te-->` are `- [Title](#title)` and
  `   - [Section](#section)`

#### Scenario: Skip header

- **WHEN** the user runs
  `gh-md-toc --hide-footer --stdout --skip-header "tests/test directory/test_stdout.md"`
- **THEN** the only line between `<!--ts-->` and `<!--te-->` is `* [Section](#section)`

### Requirement: Errors on stderr

With `--stdout`, every error SHALL be printed to stderr, the exit code SHALL be 1, and
nothing SHALL be printed to stdout:

- with no input, more than one input, or a URL as input, the program SHALL print
  `--stdout works with one local file or '-' (STDIN) only.` before any network call;
- when the document has no `<!--ts-->` line or no `<!--te-->` line, the program SHALL
  print `You don't have <!--ts--> or <!--te--> in your file...exiting` before any network
  call;
- on a GitHub API error, the program SHALL print the same messages as without `--stdout`.

Without `--stdout`, the errors SHALL go to stdout, as before this change.

#### Scenario: Two inputs

- **WHEN** the user runs `gh-md-toc --stdout README.md "tests/test directory/test_stdout.md"`
- **THEN** stderr is `--stdout works with one local file or '-' (STDIN) only.`, stdout is
  empty, and the exit code is 1

#### Scenario: URL

- **WHEN** the user runs
  `gh-md-toc --stdout https://github.com/ekalinin/github-markdown-toc/blob/master/README.md`
- **THEN** stderr is `--stdout works with one local file or '-' (STDIN) only.`, stdout is
  empty, and the exit code is 1

#### Scenario: No markers

- **WHEN** the user runs `gh-md-toc --stdout "tests/test directory/test_plussign.md"`, where
  the file has no `<!--ts-->` and `<!--te-->` lines
- **THEN** stderr is `You don't have <!--ts--> or <!--te--> in your file...exiting`,
  stdout is empty, and the exit code is 1

#### Scenario: Invalid GitHub token

- **WHEN** the user runs
  `GH_TOC_TOKEN=invalid gh-md-toc --stdout "tests/test directory/test_stdout.md"`
- **THEN** stderr has the line
  `Error: GitHub API rejected the auth token (HTTP 401 Bad credentials)`, stdout is empty,
  and the exit code is 1

### Requirement: Stdin read as is

For `-` and for `--stdout -`, the program SHALL use the document read from stdin as is:
the leading and trailing whitespace of every line SHALL be kept, and the last line SHALL
be kept when it has no newline.

#### Scenario: Indented code line

- **WHEN** the user runs `cat "tests/test directory/test_stdout.md" | gh-md-toc -`
- **THEN** the output is `* [Title](#title)` and `   * [Section](#section)`, with no
  entry for `    # indented code, not a heading`

#### Scenario: Last heading without a newline

- **WHEN** the user runs `printf '# A\n\n## B' | gh-md-toc -`
- **THEN** the output is `* [A](#a)` and `   * [B](#b)`

### Requirement: Help lists the option

`--help` SHALL list `--stdout` in the "Options" section right after `--hide-footer`.

#### Scenario: Help output

- **WHEN** the user runs `gh-md-toc --help`
- **THEN** the line after
  `  --hide-footer       Do not write date & author of the last TOC update. Set --insert as well. Default: false.`
  is
  `  --stdout            Print the whole file with the new TOC to stdout. The file is not changed. Default: false.`
