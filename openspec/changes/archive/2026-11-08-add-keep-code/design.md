# Design

## Context

See proposal.md - Why for the symptoms and specs/toc-keep-code/spec.md for the
requirements.

`gh_toc_grab` turns the HTML into the TOC with one pipeline:

```
sed: join "\n</h", "\n<span"
  |
grep: <hN ... class="heading-element">...</a          one heading per line
  |
sed: remove <code>, </code>                           since #13
  |
sed: remove <g-emoji ...>...</g-emoji>
  |
awk: text = from the first "> to </h                  per branch (default, OS/390)
     common_awk_script:
       depth filter
       gsub(/<[^>]*>/, "", text)                      since #185
       skipped level warning, numbers, bullet, link
```

Since #185, the `<code>` `sed` step is redundant: the awk `gsub` removes every tag of
the text. The OS/390 branch takes the text with `/<\/span><\/a>[^<]*<\/h/`, an
expression for the old GitHub HTML layout, so its entries have no text on the current
markup (#204).

The inline code in the HTML, both from the markdown API and on a remote GitHub page
(checked on `tests/test directory/test_backquote.md` on github.com):

- a `<code>` element without attributes;
- inside it, GitHub escapes `<`, `>` and `&` as `&lt;`, `&gt;`, `&amp;`, and writes `"`
  and `'` as they are (`` `"q'` `` gives `<code>"q'</code>`), so there are no tags
  inside;
- `:rocket:` inside the code stays text, there is no `<g-emoji>` in it.

`gh_toc_grab` is called in four places, and only the local file call passes `$6`
(`need_replace`):

```
gh_toc         remote URL   gh_toc_grab "$gh_src_copy" ... "$bullet"
gh_toc         local file   gh_toc_grab "$gh_src_copy" ... "$bullet" "$need_replace"
gh_toc_stdout  --stdout     gh_toc_grab "" ... "$bullet"
gh_toc_app     stdin (-)    gh_toc_grab "" ... "$bullet"
```

`gh_toc_app` parses `--indent`, `--depth`, `--numbered`, `--bullet` and checks their
values. Then it handles `-` (stdin) and returns, and only after that parses `--insert`
and the rest.

Constraints: BSD awk on macOS (20200816), mawk in the Docker image (Debian) and on Debian
and Ubuntu, GNU awk, the OS/390 branch, `make lint` (shellcheck).

## Goals / Non-Goals

**Goals:**

- Without `--keep-code`, the same output byte for byte, on every branch.
- The code spans built in one place, `common_awk_script`, for both branches.

**Non-Goals:**

- Removing the redundant `<code>` `sed` step for the default path.
- Passing the options of `gh_toc_grab` in another way than positional parameters.

## Decisions

### The name `--keep-code`

The name says what the user gets: the code stays code. `--no-code-tag-removal` from #153
describes the implementation, while the option also decodes the entities and picks the
backticks. It is also 21 characters long, and the option column of `--help` has 20, so
the description would not line up with the other options.

### Parsing: right after `--bullet`

`--keep-code` changes the text of the entries, as `--bullet` changes their marker, and it
has to work with stdin, which is handled right after the value checks. So `gh_toc_app`
gets `local keep_code=""` next to `local bullet=""`, and right after the `--bullet`
check:

```bash
if [ "$1" = '--keep-code' ]; then
    keep_code="yes"
    shift
fi
```

### Passing the option: a new last parameter

- `gh_toc_grab`: `$7`, passed to awk as `-v "keep_code=$7"`. The three calls without
  `need_replace` pass `""` as `$6`, so `$7` is in place and `need_replace` stays empty
  for them as now (the remote call relies on it for the link prefix).
- `gh_toc`: a 12th parameter, `local keep_code=${12}`.
- `gh_toc_stdout`: an 8th parameter, `local keep_code=$8`.

This is how `--bullet` and `--skip-no-markers` were added.

Alternative: rely on the dynamic scope of `local` in bash, so `gh_toc_grab` sees
`keep_code` of `gh_toc_app`. No other option works that way, and the calls would no
longer show what `gh_toc_grab` depends on.

### The `<code>` `sed` step is skipped with the option

```bash
# remove code tags, unless --keep-code, see #153
if [ "$7" = "yes" ]; then cat; else sed 's/<code>//g' | sed 's/<\/code>//g'; fi |
```

Without the option, the step runs as before.

Alternatives considered:

- Remove the step: it is redundant since #185, but `--keep-code` does not need it
  removed. It stays to keep the diff small, as `fix-heading-markup` (#185) decided.
- Replace `<code>` and `</code>` with a backtick in `sed`, as #153 suggests: no entity
  decoding and always one backtick, so `` `a<b>&c` `` would give `` `a&lt;b&gt;&amp;c` ``
  (rendered as is inside a code span), and ``` `` a`b `` ``` would give `` `a`b` ``.

### The code spans in `common_awk_script`

Right after the depth filter, before the existing `gsub`:

```awk
out = ""
# keep inline code in backticks, see #153
while (keep_code == "yes" && match(text, /<code[^>]*>[^<]*<\/code>/)) {
    pre = substr(text, 1, RSTART - 1)
    code = substr(text, RSTART, RLENGTH)
    text = substr(text, RSTART + RLENGTH)
    gsub(/<[^>]*>/, "", pre)
    sub(/^<code[^>]*>/, "", code)
    sub(/<\/code>$/, "", code)
    gsub(/&lt;/, "<", code)
    gsub(/&gt;/, ">", code)
    gsub(/&amp;/, "\\&", code)
    # one backtick more than the longest run inside
    fence = "`"
    s = code
    while (match(s, /`+/)) {
        if (RLENGTH >= length(fence)) {
            fence = "`"
            for (n = 0; n < RLENGTH; n++) fence = fence "`"
        }
        s = substr(s, RSTART + RLENGTH)
    }
    # a space on each side keeps the spaces and backticks at the edges
    pad = (code ~ /[^ ]/ && (code ~ /^[ `]/ || code ~ /[ `]$/)) ? " " : ""
    out = out pre fence pad code pad fence
}
# remove tags of links, formatting and inline html, see #40
gsub(/<[^>]*>/, "", text)
text = out text
```

- The tags are removed from the text around each code element, not from the whole text
  after it: the decoded code can have `<b>` in it, which the `gsub` would remove
  (`a<b>&c` would become `a&c`). So `out` collects the done part, and the existing
  `gsub` runs only on the rest.
- Without the option, the loop does not run and `out` is empty, so the text is the same
  as before.
- `&amp;` is decoded last, so a literal `&lt;` in the code (`&amp;lt;`) stays `&lt;`.
  `"\\&"` is a literal `&` in the replacement of `gsub`.
- `pre`, `code` and the rest of `text` are taken before the inner `match`, which
  overwrites `RSTART` and `RLENGTH`.
- `[^<]*` is enough for the content: there are no tags inside the code.
- The padding follows CommonMark: one space is stripped from each side of a code span
  that starts and ends with a space, unless it is only spaces. So a code of only spaces
  gets no padding.
- New awk variables: `out`, `pre`, `code`, `fence`, `s`, `n`, `pad`. None of them is used
  by the script now (`num` is, so it is not reused).
- The skipped level warning (#75) prints `text`, so it shows the backticks too, as the
  TOC entry does.

### Help, README

`show_help` gets
`  --keep-code         Keep inline code of headings in backticks. Default: false.`
right after the `--bullet` line; the description starts at the same column as the other
options.

README, section "Local files": after the `--bullet` example, a sentence and an example:

````
To keep the inline code of the headings in backticks, use `--keep-code`:

```bash
➥ printf '# The command `foo1`\n\n## The command `foo2` is better\n' | ./gh-md-toc --keep-code -
* [The command `foo1`](#the-command-foo1)
   * [The command `foo2` is better](#the-command-foo2-is-better)
```
````

The example is in a code block and adds no heading, so the README TOC in
`tests/tests.bats` does not change.

### Tests

- A new fixture `tests/test directory/test_keepcode.md` with the headings of the spec
  scenario, separated by empty lines. For none of them GitHub puts a line break after the
  heading tag (#201), checked with the markdown API; ``## *em `code`* and ...`` had one,
  so the heading starts with `A`.
- "TOC with inline code in backticks for local file, #153": every entry and the footer.
- "TOC with inline code without --keep-code for local file, #153": the same fixture
  without the option; it passes before the implementation and pins down the default.
- "TOC with inline code in backticks for markdown from stdin, #153":
  `--bullet - --keep-code -` on `test_backquote.md`, 5 lines.
- "TOC with inline code in backticks for remote file, #153": the URL of the spec
  scenario, pinned to a commit like the `sitemap.js` URL of the other remote tests.
- "Whole file with inline code in backticks to stdout, #153": `a.md` written into
  `$BATS_TEST_TMPDIR` with `printf`, `run_to_files`, stdout and the file compared with
  `cmp`, as the #62 tests do.
- `test_help`: the new line at index 11, the following lines one index further, 20 lines
  in total.

Before the implementation, `--keep-code` is taken as an input, a missing file, so the
four tests with the option and `test_help` fail.

### Checked

On a temporary copy of the script with the parsing replaced by an environment variable:

- The fixture gives the entries of both spec scenarios, byte for byte the same with BSD
  awk 20200816 (macOS), mawk 1.3.4 and GNU awk 5.2.1 (Debian container).
- The TOC entries made with `--keep-code`, rendered by the markdown API, have the same
  `<code>` content as the headings, for all 13 code spans of the fixture.
- Without the option, `README.md` and every fixture in `tests/test directory/` give the
  same output as master.

## Risks / Trade-offs

- [GitHub adds attributes to `<code>`] → `<code[^>]*>` matches them with the option.
  Without it, the `sed` step and the awk `gsub` remove the tags as now.
- [GitHub puts tags inside `<code>`] → The element does not match, and its tags are
  removed as without the option, so the entry has the code without backticks.
- [GitHub escapes `"` or `'` inside code in the future] → They would be written as
  `&quot;` or `&#39;` in the code span. Today they are written as they are.
- [Five new tests call the GitHub API or load a page from github.com] → Same as the
  existing tests: `GH_TOC_TOKEN` locally, `secrets.GITHUB_TOKEN` in CI.
