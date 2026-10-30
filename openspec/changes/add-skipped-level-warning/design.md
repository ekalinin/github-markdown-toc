# Design

## Context

See proposal.md - Why for the symptoms and specs/toc-skipped-level/spec.md for
requirements.

Every input ends in `gh_toc_grab`. Its `common_awk_script`, shared by the default and the
OS/390 branches, first drops entries deeper than `--depth` with `next` and removes the
tags from `text`. Then it builds the `--numbered outline` number from a stack of levels:

```
prev = 0
while (top > 0 && lvls[top] >= level+0) { prev = nums[top]; top-- }
top++; lvls[top] = level+0; nums[top] = prev + 1
```

After the `while`, `lvls[top]` is the level of the parent from the spec, and `top` is 0
when the entry has no parent.

The stdout of awk never goes to the terminal directly: `gh_toc_grab` ends with
`echo $echoargs "$(awk ...)"`, and `gh_toc` (local file, `--insert`) and `gh_toc_stdout`
capture the TOC once more with `toc=$(... | gh_toc_grab ...)`. Nothing captures or
redirects the stderr of awk, so it goes to the stderr of `gh-md-toc` for every input.

The first argument of `gh_toc_grab` is passed to awk as `gh_url`. It is empty for one
input (`gh_toc` clears `gh_src_copy` when there is one document), for stdin and for
`--stdout`, and it is the input as given for several inputs.

`common_awk_script` is a single-quoted shell string. It already uses the names `top`,
`lvls`, `nums`, `prev`, `num`, `k`, `modified_href`, `chars`, `c`, `res`, `i`, `marker`,
`prefix`, `count`, `entry_level`, `entry`, `min_level`, and gets `level`, `text`,
`anchor`, `href` from the branches and `gh_url`, `depth`, `numbered`, `bullet` from `-v`.

Constraints: BSD awk 20200816 on macOS (checked), mawk on `ubuntu-latest` in CI, the
same awk code on OS/390, `make lint` (shellcheck), bats 1.6.0 in CI and 1.14.0 locally.

## Goals / Non-Goals

**Goals:**

- One change point in `common_awk_script` that covers all inputs and both awk branches.
- stdout stays byte-for-byte the same for every input.

**Non-Goals:** see proposal.md - Non-goals.

## Decisions

### Check against the parent right before the push

Between the `while` and the push, print the warning when
`top > 0 && level+0 > lvls[top] + 1`. The push also keeps the text of the entry in a new
array `txts[top]`, so the warning can name the parent. `text` at this point has no tags
and no outline number, the same text as in the entry.

The parent is the one the outline numbers already use, so the warning and
`--numbered outline` can not disagree about the tree. The check runs after the
`--depth` `next`, so only the entries in the TOC are checked.

Alternative: compare with the level of the previous entry. For `# A`, `#### B`, `### C`
it warns only about `B`, but `C` (6 spaces under `A`) is also rendered as text of `A`.
The parent rule warns about both.

### Print to stderr through `| "cat 1>&2"`

`print ... | "cat 1>&2"` uses only `sh` and `cat`, which POSIX awk supports. Every
warning uses the same command string, so awk keeps one pipe and the lines stay in
document order. awk closes the pipe at exit and waits for `cat`, so all warnings are
written before the shell prints the captured TOC.

Alternative: `print > "/dev/stderr"`. gawk, mawk and BSD awk handle this name (checked
with BSD awk 20200816), but POSIX does not define it, and it is not checked on OS/390.

### The message in a single-quoted shell string

- The single quotes of the message are written as `\047` inside the awk string, because
  a `'` would end the shell string. `\047` is an octal escape of POSIX awk (checked with
  BSD awk 20200816). Alternative: `'\''` splices, harder to read in a long line.
- The prefix for several inputs is `(gh_url != "" ? gh_url ": " : "")`. No new awk
  variable is needed: `gh_url` is empty in exactly the cases with one document.

### Where the warning appears

In a terminal, the warning appears when awk runs: for one input after the
`Table of Contents` header, which `gh_toc` prints before it builds the TOC, and before
the TOC lines:

```
Table of Contents
=================

Warning: heading 'Skipped' (level 3) skips a level after 'Title two' (level 1), see https://github.com/ekalinin/github-markdown-toc/issues/75
* [Title one](#title-one)
...
```

`gh-md-toc README.md > toc.md` writes only the TOC into the file.

### Tests

bats `run` captures stdout and stderr together into `output` and `lines`, so the
warning would be a new line in the three tests listed in proposal.md - Impact. A new
helper next to `run_to_files` runs `gh-md-toc` with `2>/dev/null`, and only the `run`
line of each of the three tests changes. Their assertions stay as they are, so they also
check that stdout does not change.

Alternatives:

- `run --separate-stderr`: bats 1.14.0 prints a warning for it unless the file calls
  `bats_require_minimum_version` (checked in `lib/bats-core/warnings.bash`), and it is
  not checked whether that function exists in bats 1.6.0 used in CI.
- Shift the line indexes in the three tests and assert the warning there: about 24
  changed assertion lines instead of 3 `run` lines.

The new tests use `run_to_files`, which keeps stdout and stderr in separate files with
exact bytes: stderr is compared as a whole, so a missing, extra or reordered warning
fails the test. The `printf` inputs from the spec go to stdin as in the existing
`printf '# A\n\n## B' | { run ... }` test; the `--insert` scenario writes its file into
`$BATS_TEST_TMPDIR`.

## Risks / Trade-offs

- [mawk or OS/390 awk handles the output pipe differently] → The CI suite runs with
  mawk and compares stderr exactly. OS/390 can not be checked here; the pipe uses only
  POSIX awk, `sh` and `cat`.
- [Scripts that merge stderr into stdout (`2>&1`) or treat any stderr as a failure now
  see the warning] → The exit code stays the same, and a plain `>` redirect keeps the
  warning out of the file.
- [A warning when GitHub still renders a nested list: `--indent 2` or `--numbered list`
  with one skipped level] → Accepted (proposal.md - Non-goals): the rule depends only on
  the headings.
- [HTML entities in the message: `Tom & Jerry` is shown as `Tom &amp; Jerry`] → The same
  text as in the TOC entry (`toc-heading-markup` keeps entities).
