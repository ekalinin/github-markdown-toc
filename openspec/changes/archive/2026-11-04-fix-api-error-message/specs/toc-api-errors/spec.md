# Spec Delta

## Purpose

Tells the user why the GitHub API rejected a document: for an API error that is not a
network error, bad credentials or the rate limit, the program prints the message that
GitHub sends with the HTTP code.

## ADDED Requirements

### Requirement: Message from the GitHub API

When the GitHub API answers a local file, stdin or `--stdout` with an HTTP status other
than 200, and the error is not bad credentials (401) or the rate limit, the program SHALL
print `Parsing local markdown file requires access to github API` and
`Error: GitHub API request failed (HTTP <code>)`, as before, and then, when the answer has
a `message` field, a line with its value. Without a `message` field, the program SHALL
print only the first two lines. The exit code SHALL be 1. With `--stdout`, the lines SHALL
go to stderr. The messages for network errors, bad credentials and the rate limit SHALL
NOT change.

#### Scenario: File larger than the API limit

- **WHEN** the user runs `gh-md-toc <file>`, where the file has 1048576 bytes
- **THEN** the output has the lines
  `Parsing local markdown file requires access to github API` and
  `Error: GitHub API request failed (HTTP 403)`, followed by the message from GitHub, which
  has `too large`, and the exit code is 1
