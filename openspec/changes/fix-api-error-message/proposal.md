# Proposal

## Why

When the GitHub API answers with an error other than a network error, bad credentials
(401) or the rate limit, the program prints only the HTTP code and drops the reason that
GitHub sends with it. For a local file larger than the API limit (#141), the output is:

```
Parsing local markdown file requires access to github API
Error: GitHub API request failed (HTTP 403)
```

GitHub answered with
`This API renders Markdown text up to 400 KB in size. The requested text is too large to render via the API.`,
but the user does not see it. The #141 reporter thought it was a syntax error in the file.
Reproduced with the current master:

- The #141 wiki page (`0-IndiMail Wiki.md`) is now 638679 bytes; the API answers it with
  HTTP 403 and the message above. A file of 409600 bytes renders, 409601 bytes does not;
  the limit counts bytes, not characters.
- 0.8.0, the version from #141, prints an empty TOC with exit code 0 for this file; the
  current version prints the two lines above with exit code 1.
- The remote URL of the page gives the TOC (160 entries): GitHub renders the page itself,
  without the API.

## What Changes

- For a GitHub API error that is not a network error, bad credentials or the rate limit,
  print the `message` from the API answer as a third line, after
  `Error: GitHub API request failed (HTTP <code>)`. The first two lines do not change.
- When the answer has no `message`, print the two lines as before.
- This applies to a local file, stdin and `--stdout` (on stderr, as before).
- Add a test with a file larger than the API limit.

Output change: for such errors, one more line with the message from GitHub. Network
errors, bad credentials and the rate limit give the same output as before.

Non-goals:

- A TOC for files larger than the API limit, for example by splitting the file: it would
  mean parsing markdown, and anchors of repeated headings would differ from GitHub.
- A check of the file size before the API call: the limit would be a number in the
  script, and GitHub can change it.
- Changes to the messages for network errors, bad credentials and the rate limit, or to
  the first line `Parsing local markdown file requires access to github API`.
- Changes to README, the landing page (`site/`), or `openspec/specs/landing`.
- A version bump.

## Capabilities

### New Capabilities

- `toc-api-errors`: the error output for a GitHub API error that is not a network error,
  bad credentials or the rate limit.

### Modified Capabilities

None. `toc-stdout` (Errors on stderr) stays true: with `--stdout` the program prints the
same messages as without it, on stderr.

## Impact

- `gh-md-toc`: `gh_toc_md2html` (the error marker for other API errors) and
  `gh_toc_check_api_error` (the printed lines).
- `tests/tests.bats`: one new test. No new fixtures.
- Closes #141.
