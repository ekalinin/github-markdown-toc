# toc-markers Specification

## Purpose

Defines which lines count as the `<!--ts-->` and `<!--te-->` markers for `--insert`,
`--stdout` and `--skip-header`, and keeps CRLF line endings when the TOC is put between
the markers of such a file.

## Requirements

### Requirement: Marker lines

A line SHALL count as the `<!--ts-->` marker when it starts with `<!--ts-->` and has only
whitespace after it, such as spaces, tabs and a carriage return. The same SHALL apply to
`<!--te-->`. A line with any other character before the marker, such as indentation, SHALL
NOT count. This SHALL apply to `--insert`, `--stdout` and `--skip-header`. The marker
lines SHALL be kept as they are.

#### Scenario: Trailing whitespace after the markers

- **WHEN** the user runs `gh-md-toc --insert --no-backup --hide-footer <file>`, where the
  file is `<!--ts--> \t\n<!--te-->  \n\n# Title\n`
- **THEN** the file is `<!--ts--> \t\n* [Title](#title)\n<!--te-->  \n\n# Title\n`, and
  the exit code is 0

#### Scenario: Indented markers

- **WHEN** the user runs `gh-md-toc --insert --no-backup --hide-footer <file>`, where the
  file is `    <!--ts-->\n    <!--te-->\n\n# Title\n`
- **THEN** stdout has the line
  `You don't have <!--ts--> or <!--te--> in your file...exiting`, the file does not
  change, and the exit code is 1

#### Scenario: Skip header with CRLF line endings

- **WHEN** the user runs `gh-md-toc --skip-header <file>`, where the file is
  `# Header\r\n\r\n<!--ts-->\r\n<!--te-->\r\n\r\n# Title\r\n\r\n## Section\r\n`
- **THEN** the TOC entries are `* [Title](#title)` and `   * [Section](#section)`

### Requirement: CRLF line endings

When the `<!--ts-->` line ends with a carriage return, every line that `--insert` writes
between the markers, and every line that `--stdout` prints between them, SHALL end with
`\r\n`: the TOC entries, the empty lines and the footer lines. Otherwise these lines SHALL
end with `\n`. All other lines of the file SHALL be kept as they are.

#### Scenario: Insert into a file with CRLF line endings

- **WHEN** the user runs `gh-md-toc --insert --no-backup <file>`, where the file is
  `<!--ts-->\r\n<!--te-->\r\n\r\n# Title\r\n\r\n## Section\r\n`
- **THEN** the lines between `<!--ts-->` and `<!--te-->` are `* [Title](#title)`,
  `   * [Section](#section)`, an empty line,
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->`,
  `<!-- Added by: <user>, at: <date> -->` and an empty line, every line of the file ends
  with `\r\n`, and the exit code is 0

#### Scenario: Whole file to stdout with CRLF line endings

- **WHEN** the user runs `gh-md-toc --hide-footer --stdout <file>`, where the file is
  `<!--ts-->\r\n<!--te-->\r\n\r\n# Title\r\n\r\n## Section\r\n`
- **THEN** stdout is
  `<!--ts-->\r\n* [Title](#title)\r\n   * [Section](#section)\r\n<!--te-->\r\n\r\n# Title\r\n\r\n## Section\r\n`,
  and the exit code is 0
