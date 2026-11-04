# Design

## Context

See proposal.md - Why for the symptoms and specs/toc-api-errors/spec.md for requirements.

`gh_toc_md2html` sends the document with `curl -w '\n%{http_code}'`, splits the status
from the body (`OUTPUT`) and returns either the HTML or an error marker, which
`gh_toc_check_api_error` turns into the printed lines:

```
curl_status != 0                          -> XXNetworkErrorXX
http_code = 401                           -> XXBadCredentialsXX
http_code != 200, "API rate limit exceeded" in OUTPUT
                                          -> XXRateLimitXX
http_code != 200                          -> XXApiErrorXX <code>
                                               |
gh_toc_check_api_error                         v
  "Parsing local markdown file requires access to github API"
  "Error: GitHub API request failed (HTTP <code>)"
```

For an error, `OUTPUT` is the JSON answer of the API, with `"message": "..."` on its own
line:

```
{
  "message": "This API renders Markdown text up to 400 KB in size. The requested text is too large to render via the API.",
  "errors": [ ... "code": "too_large" ... ],
  ...
}
```

`gh_toc_check_api_error` is called for a local file (`gh_toc`), stdin (`gh_toc_app`) and
`--stdout` (`gh_toc_stdout`, with `>&2`). No test covers the `XXApiErrorXX` branch now.

Constraints: BSD awk on macOS, mawk or gawk on Linux, OS/390 (where `grep -o` is replaced
by `pcregrep` in `gh_toc_grab`), `make lint` (shellcheck).

## Goals / Non-Goals

**Goals:**

- Change only the `XXApiErrorXX` branch in `gh_toc_md2html` and in
  `gh_toc_check_api_error`; the three callers stay as they are.

**Non-Goals:**

- A test for an answer without `message`: the API gives no way to get one on purpose.

## Decisions

### Take the message with `awk` in `gh_toc_md2html`, pass it in the marker

In the `XXApiErrorXX` branch, take the first `"message": "..."` from `OUTPUT`:

```
awk 'match($0, /"message": *"[^"]*"/) { s = substr($0, RSTART, RLENGTH); sub(/^"message": *"/, "", s); sub(/"$/, "", s); print s; exit }'
```

and return `XXApiErrorXX <code> <message>`. In `gh_toc_check_api_error`, split the code
from the message at the first space, print the two lines as before, and print the message
as a third line when it is not empty.

A JSON string cannot have a raw newline, so the marker stays one line.

Checked with BSD awk 20200816 and mawk on the API answer for the #141 file
(`This API renders Markdown text up to 400 KB in size. ...`), on a one-line answer
(`{"message":"Not Found",...}` gives `Not Found`) and on a non-JSON answer (gives an empty
string).

Alternatives considered:

- Take the message in `gh_toc_check_api_error`: it gets only the marker, so the three
  callers would have to pass the body too.
- `grep -o` or `sed`: `grep -o` is not used outside the OS/390 branch for a reason, and
  `awk` is already used for the rate limit check on the same `OUTPUT`.
- `jq`: a new dependency.
- Print the whole JSON answer: several lines of JSON for a one-line reason.

### Test

One new test, "Error for local file larger than the GitHub API limit, #141", writes a
1048576-byte file of `a` into `$BATS_TEST_TMPDIR` (`head -c 1048576 /dev/zero | tr '\0'
'a'`), runs `gh-md-toc` on it, and asserts `assert_fail`, `${lines[2]}` (`Parsing ...`),
`${lines[3]}` (`Error: GitHub API request failed (HTTP 403)`), and that `${lines[4]}` has
`too large`.

The file is well above the limit found for #141 (409600 bytes), so the test does not
depend on the exact limit; the API answers 1048576 bytes with the same HTTP 403 and
message. The test checks only `too large` in the message, since the text is GitHub's.

Before the change there is no `${lines[4]}`, so the test fails.

The existing tests for network errors and bad credentials keep their lines.

## Risks / Trade-offs

- [A message with an escaped quote (`\"`) is cut at it: `a \"b\"` gives `a \`] → The
  messages of this endpoint have no quotes; the HTTP code is still printed.
- [GitHub changes the text or the limit] → The test checks only `too large` and uses a
  file well above the limit. If the text changes, the program prints the new text.
- [The test sends 1 MiB to the API on every run] → One request; the other tests already
  call the API.
