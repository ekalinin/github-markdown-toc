# Design

## Context

Every input path ends in `gh_toc_grab`. Its awk script reads the level as
`substr($0, 3, 1)` and prints each entry in `common_awk_script`, which is shared by the
default and the OS/390 branches. The `--depth` filter (`next`) is at the start of
`common_awk_script`, and the entry is printed at its end as
`sprintf("%*s", (level-1)*indent, "") "* [" text "](" gh_url modified_href ")"`.
`common_awk_script` already uses the names `modified_href`, `chars`, `c`, `res` and
`i`.

`gh_toc_app` checks each option once, in a fixed order: `--indent`, `--depth`, `-`,
`--insert`, `--no-backup`, `--hide-footer`, `--skip-header`, then the inputs. `--depth`
reaches awk as `-v "depth=$3"`.

What GitHub renders (checked with the GitHub markdown API and `github-markdown-css`):

- Nested `<ol>` use `lower-roman`, then `lower-alpha`, so an ordered list cannot show
  `2.1`.
- A child of an ordered item is nested only when its indent is from 3 to 6 spaces more
  than the parent marker: with 2 or 7 spaces the entries are not nested.
- A child indented 3 spaces under the marker `10.` is not nested, and the list gets
  `start="10"`.
- `* 1. [A](#a)` is a bullet with an ordered list inside, while `* [1. A](#a)` is a
  bullet with the link text `1. A`.

## Goals / Non-Goals

**Goals:**

- One change point for the entry format that covers all inputs and both awk branches.
- The output without `--numbered` stays byte-for-byte the same.
- The errors happen before any network call.

**Non-Goals:** see proposal.md - Non-goals.

## Decisions

### One option with a type

`--numbered <TYPE>`, where `TYPE` is `list` or `outline`. The two types are two
different looks of the same thing, and they cannot be used together.

Alternative: two flags, e.g. `--ordered` and `--outline`. They would need a rule for
the case when both are given, and the fixed-order parser would need two more positions.

### `list`: `1.` for every entry

The marker is the constant `1.`. GitHub takes the number of only the first item of a
list, so the rendered TOC is numbered `1, 2, 3` anyway. A constant marker is always two
characters wide, so the default indent of 3 nests every child.

Alternative: real counters (`1.`, `2.`, ...). The raw markdown reads better, but a
parent with a marker of two digits (`10.`) needs an indent of 4 for its children, which
breaks the `(level - 1) * indent` rule, and the counters must be reset for every
sublist, or the sublist gets a `start` attribute.

### `outline`: number inside the link text

The entry is `* [2.1. Section](#section)`. A number before the link (`* 2.1. [Section]`)
is parsed as an ordered list marker inside the bullet (see Context).

### `outline`: numbers from a stack of entries

The awk script keeps a stack of the entries on the current path of the tree: their
levels (`lvls[1..top]`) and their numbers among siblings (`nums[1..top]`). For each
entry:

```awk
prev = 0
while (top > 0 && lvls[top] >= level+0) { prev = nums[top]; top-- }
top++; lvls[top] = level+0; nums[top] = prev + 1
num = ""
for (k = 1; k <= top; k++) num = num nums[k] "."
```

Popping all entries with a level greater than or equal to the new one leaves its parent
on top, and the last popped entry is its previous sibling, so its number is the next
one. The names `top`, `lvls`, `nums`, `prev`, `num` and `k` do not clash with the names
already used in `common_awk_script`. This code goes after the `--depth` filter, so the
filtered headings do not take numbers.

Alternative: one counter per heading level, with the deeper counters reset after each
entry, and the number made of the non-zero counters. It gives the same number twice for
`#`, `###`, `##` (`1.1.` and `1.1.`) and for a document that starts with `##` before
its `#` (`1.` and `1.`).

### `numbered` passed to awk with `-v`

`gh_toc_grab` gets the type as a new fourth argument and passes it as
`-v "numbered=$4"`, next to `depth`. The print at the end of `common_awk_script` picks
the marker and the text prefix by `numbered`: `1. ` and nothing for `list`, `* ` and
`num " "` for `outline`, `* ` and nothing otherwise.

Alternative: splice the value into the script text, as done for the indent. An empty
value would need quoting rules inside the awk script; `-v` already works for `depth`.

### Parsing and checks in `gh_toc_app`

`gh_toc_app` gets `local numbered=""` next to `local depth=0`, and a `--numbered` check
right after the `--depth` check and before the `-` check, so stdin supports it. Right
after it, before the `-` branch, two checks print their message and `exit 1` (see the
spec, Invalid usage): the type must be empty, `list` or `outline`, and `list` needs an
indent of 3 or more. The indent check is `[ "$indent" -lt 3 ] 2>/dev/null`, so a
non-numeric indent, which is not validated today, does not print a shell error and is
not reported. The messages go to stdout, like the existing errors.

The value goes to the stdin branch as
`gh_toc_grab "" "$indent" "$depth" "$numbered"` and to `gh_toc` as a new last (9th)
parameter, which passes it to both of its `gh_toc_grab` calls.

Alternative: check the values in `gh_toc_grab`. It runs once per input and after the
network call, so an error would come after a request to the GitHub API, and once for
every input.

### Dedicated test fixture

`tests/test directory/test_numbered.md` with the headings `# Title one`, `## Section`,
`### Subsection`, `## Other section`, `# Title two`, `### Skipped`, `## After skip`. It
covers a return to a lower level, a return to the top level, a skipped level, and a
sibling after a skipped level. `test_depth.md` has none of the last three.

## Risks / Trade-offs

- [In `outline`, an entry under a skipped level is indented 6 spaces, and GitHub renders
  it as text of the parent entry] → Accepted: the same happens to bullets today, and
  the indentation is out of scope (#30, #75).
- [In `list`, an indent over 6 breaks the nesting] → Accepted, see proposal.md -
  Non-goals.
- [The raw markdown of `list` shows `1.` for every entry] → Accepted: the rendered
  numbers are right, see the decision above.
- [With several inputs in `list`, the TOCs are separated only by a blank line, so
  GitHub renders them as one list with continued numbers] → Accepted: the bullet TOCs
  are joined into one list in the same way today.
- [`--numbered` after another option, e.g. `--insert --numbered list README.md`, is
  taken as an input] → `--help` lists `--numbered` right after `--depth`, which matches
  the parse order. The same limitation applies to every option.
- [The new tests for a local file and stdin call the GitHub API] → Same as the existing
  tests: `GH_TOC_TOKEN` locally, `secrets.GITHUB_TOKEN` in CI.
