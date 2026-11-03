# Design

## Context

See proposal.md - Why for the symptoms and specs/toc-multiple-inputs/spec.md for
requirements.

With more than one input, `gh_toc` keeps `gh_src_copy` as the input given on the command
line (with one input it sets it to `""`) and passes it to `gh_toc_grab`, which passes it to
awk as `gh_url`. In `common_awk_script`, shared by the default and the OS/390 branches,
`gh_url` is used twice:

```
awk -v gh_url="$1"
   |
   +--> warning: gh_url ": Warning: heading ..."            stderr, #75
   |
   +--> entry:   link_url = gh_url, spaces to %20 (#76)
                 marker "[" prefix text "](" link_url modified_href ")"
```

`toc-skipped-level` (Every input) requires the warning to start with `<input>: ` with
several inputs, also with `--insert`. So the link must lose the prefix, and the warning
must keep it.

`gh_toc` has two branches:

```
gh_toc
   |
   +--> remote URL:  gh_toc_load | gh_toc_grab "$gh_src_copy" ...   -> stdout only
   |                 with --insert: "!! ... is not a local file"
   |
   +--> local file:  toc=$(... | gh_toc_grab "$gh_src_copy" ...)
                     echo "$toc"                                  -> stdout
                     with --insert: echo "${toc}" > "${toc_path}" -> the file
```

`gh_toc_grab` has two more callers, `gh_toc_stdout` and stdin in `gh_toc_app`, and both
pass `""` as `$1`.

Constraints: BSD awk on macOS, GNU awk on Linux, the same awk code on OS/390,
`make lint` (shellcheck).

## Goals / Non-Goals

**Goals:**

- Change only the link of an entry of a local file with `--insert`, in one place that both
  awk branches share.
- Keep the call sites of `gh_toc_grab` that do not need the change as they are.

**Non-Goals:**

- A new fixture: the test creates its files in `$BATS_TEST_TMPDIR`, as the #75 tests do.

## Decisions

### A sixth parameter of `gh_toc_grab`, used only for the link

Add `$6` to `gh_toc_grab`: `"yes"` when the TOC is written into the file itself. Pass it to
awk as `-v "need_replace=$6"`, and in `common_awk_script` take the link prefix from
`gh_url` only when it is not `"yes"`:
`link_url = (need_replace == "yes" ? "" : gh_url)`. The warning keeps `gh_url`.

Only the call in the local branch of `gh_toc` passes `"$need_replace"`. The remote branch,
`gh_toc_stdout` and stdin pass five arguments as before, so `$6` is empty there and their
output does not change. Add `$6` to the comment above `gh_toc_grab`.

The name `need_replace` is the one `gh_toc` and `gh_toc_app` already use for `--insert`.

Alternatives considered:

- Pass `""` instead of `"$gh_src_copy"` in the local branch with `--insert`: one line, but
  the warning loses `<input>: ` and breaks `toc-skipped-level` (Every input).
- Set `gh_src_copy=""` at the top of `gh_toc` with `--insert`, next to the one-input check:
  also drops the prefix of a remote URL and breaks `remote-toc` (Remote page among multiple
  inputs), and the warning loses `<input>: ` too.
- Pass the link prefix from every call site as a separate value: changes all four call
  sites for the same result.
- Remove the prefix from `toc` with `sed` in bash: the input can have characters that are
  special in a regex, and the prefix in `toc` has `%20` instead of spaces.

### stdout shows what is written into the file

In the local branch, `toc` is computed once, printed, and written into the file. With the
change, both have `#<anchor>`, and no second call of `gh_toc_grab` is needed.

### Tests

One new test writes `a.md` (`<!--ts-->`, `<!--te-->`, `# Page a`, `## Usage`) and `b.md`
(`<!--ts-->`, `<!--te-->`, `# Title`, `### Skipped`) into `$BATS_TEST_TMPDIR` with
`printf`, runs `run_to_files --insert --no-backup --hide-footer` with both files and the
remote sitemap.js README from "TOC for mixed README.md (remote/local)", and asserts:

- lines 2 and 3 of each file, as in the spec scenario "Two local files and a remote URL";
- the entries of both files and the first remote entry in `out.md`, with `grep -Fx`;
- `err.txt` is `"$BATS_TEST_TMPDIR/b.md: Warning: ..."`.

Before the change, the lines in the files are `* [Page a]($BATS_TEST_TMPDIR/a.md#page-a)`
and so on, so the test fails.

The other scenarios are already covered by existing tests, which stay unchanged:

- "Two local files in a directory with a space": "TOC for several files with a space in
  the path, #76".
- "Warning keeps the input as given": "Warning for skipped heading level for several
  files, #75".
- "Input without a space": "TOC for mixed README.md (remote/local)".

## Risks / Trade-offs

- [A TOC that `--insert` put into a file with several inputs changes on the next run] →
  Stated in proposal.md as an output change. The new links work on every host, the old
  ones did not.
- [Someone uses the TOC block inside a file as links from another place] → Not reported.
  With one input, `--insert` already writes `#<anchor>`.
