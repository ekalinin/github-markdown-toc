# Design

## Context

Every input path ends in `gh_toc_grab`: stdin and local files go through
`gh_toc_md2html`, remote URLs through `gh_toc_load`. In `gh_toc_grab` an awk script takes
one line per heading, reads the level as `substr($0, 3, 1)` (the digit in `<hN`), and
prints the entry in `common_awk_script`, which is shared by the default and the OS/390
branches.

`gh_toc_app` checks each option once, in a fixed order: `--indent`, `-`, `--insert`,
`--no-backup`, `--hide-footer`, `--skip-header`, then the inputs. An option out of this
order is taken as an input.

## Goals / Non-Goals

**Goals:**

- One filter that covers all inputs and both awk branches.
- The existing output without `--depth` stays byte-for-byte the same.

**Non-Goals:** see proposal.md - Non-goals.

## Decisions

### Absolute level, as in the Go version

`--depth N` keeps headings with level `<= N`, and `0` means no limit. This is what
`internal/core/toc/renderer.go` in `github-markdown-toc.go` does
(`Depth > 0 && heading.Level > Depth` is skipped), so both versions behave the same.

Alternative: a relative depth, counted from the highest level present in the document.
It needs a second pass to find that level first, differs from the Go version, and
mostly helps documents without `#`, which is the topic of #30 and #75.

### Filter in `common_awk_script`

The condition goes at the start of `common_awk_script`, where `level` is already set
and before anything is printed:

```awk
if (depth+0 > 0 && level+0 > depth+0) next
```

`+0` makes the comparison numeric: `substr()` returns a string, and awk compares a
string with a `-v` value as strings.

Alternative: narrow the grep pattern to `<h[1-N]`. It changes the regex used by both
`grep -Eo` and `pcregrep -o`, needs a special case for `0`, and this pattern was the
source of #166.

### `depth` passed to awk with `-v`

`gh_toc_grab` gets the depth as a new third argument and passes it as
`-v "depth=$3"`, next to `-v "gh_url=$1"`. An empty value is then just `0` in awk.

Alternative: splice the value into the script text, as done for the indent
(`'"$2"'`). An empty value would leave an expression without an operand, which is an
awk syntax error, so the script would depend on the caller always passing a number.

### Parsing in the existing order

`gh_toc_app` gets `local depth=0` next to `local indent=3`, and a
`--depth` check right after the `--indent` check and before the `-` check, so stdin
supports it. The value goes to the stdin branch as `gh_toc_grab "" "$indent" "$depth"`
and to `gh_toc` as a new last (8th) parameter, which passes it to both of its
`gh_toc_grab` calls. Adding the parameter at the end keeps the positions of the
existing ones.

Alternative: a `while`/`case` loop that accepts options in any order. It is a rewrite
of `gh_toc_app` that touches every option and is out of scope.

### Dedicated test fixture

`tests/test directory/test_depth.md` with the headings `# Title one`, `## Section`,
`### Subsection`, `#### Deep`, `# Title two`. `test_backquote.md` already has three
levels, but it is the fixture for #13, and reusing it would tie two unrelated tests
together.

## Risks / Trade-offs

- [`--depth` after another option, e.g. `--insert --depth 2 README.md`, is taken as an
  input and the run fails with a curl error] → `--help` lists `--depth` right after
  `--indent`, which matches the parse order. The same limitation already applies to
  every option.
- [A non-numeric value, e.g. `--depth abc`, becomes `0` in awk and silently means no
  limit] → Accepted, `--indent` is not validated either.
- [`--depth 1` on a document without `#` gives an empty TOC] → Accepted, same as the
  Go version.
- [The new tests call the GitHub API and can hit the rate limit] → Same as the existing
  local file tests: `GH_TOC_TOKEN` locally, `secrets.GITHUB_TOKEN` in CI.
