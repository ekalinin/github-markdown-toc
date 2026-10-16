# Design

## Context

Every input path ends in `gh_toc_grab`. Its awk script reads the level as
`substr($0, 3, 1)` and runs `common_awk_script`, which is shared by the default and the
OS/390 branches. `common_awk_script` drops entries deeper than `--depth` with `next`,
builds the `--numbered outline` number from a stack of levels, and prints each entry
right away as `sprintf("%*s", (level-1)*'"$2"', "") marker "[" prefix text "](" gh_url
modified_href ")"`, where `$2` is the indent spliced into the script by the shell.

`common_awk_script` already uses the names `top`, `lvls`, `nums`, `prev`, `num`, `k`,
`modified_href`, `chars`, `c`, `res`, `i`, `marker` and `prefix`. `top` is the stack
pointer of the outline numbers, not the top heading level from the specs.

Each input of several inputs goes through its own `gh_toc_grab` call (`gh_toc` is called
once per input), so one awk run sees one document.

## Goals / Non-Goals

**Goals:**

- One change point that covers all inputs and both awk branches.
- The output for a document with a `#` heading stays byte-for-byte the same.

**Non-Goals:** see proposal.md - Non-goals.

## Decisions

### `top` is the smallest level, not the level of the first entry

The indent is counted from the smallest heading level among the entries.

Alternative: count from the level of the first entry. For `###` followed by `##`, the
`##` entry would get a negative indent and would need a clamp to 0, which puts `###` and
`##` at the same indent. The smallest level never gives a negative indent and keeps the
distance between levels as it is today.

### Keep the entries in awk and print them in `END`

The smallest level is known only after the last heading. `common_awk_script` stores
each entry without the indent and its level in two arrays and updates the smallest
level. A new `END` block prints the entries in order with
`sprintf("%*s", (level - min_level) * '"$2"', "")` in front.

New awk names: `count`, `entry_level`, `entry`, `min_level`. They do not clash with the
names above.

The `END` block is a separate shell variable next to `common_awk_script`, appended to
both `awkscript` branches, so OS/390 gets the same change.

Alternatives:

- Run awk twice over the grep output (first pass for the smallest level). This needs the
  intermediate output in a variable or a temp file and doubles the pipeline tail.
- Strip the common leading spaces after awk with `sed`. The awk output still goes
  through `echo -e`, which turns `\x..` into characters, so a second text pass is harder
  to keep correct than an integer subtraction in awk.

Keeping the entries in memory is fine: a TOC has tens or hundreds of entries.

### `--depth` and `--numbered` need no changes

`--depth` drops entries with `next` before they are stored, so the smallest level is
taken over the entries in the TOC. `--depth` only drops levels deeper than `NUM`, so the
smallest level stays the same whenever the TOC is not empty.

The outline numbers are built from the order of levels, not from their absolute values,
so they already start from `1.` at the top entries.

The `--numbered list requires --indent 3 or more` check stays: nested entries still
need at least 3 spaces under the `1.` marker.

## Risks / Trade-offs

- [A TOC that `--insert` put into a file without a `#` heading changes on the next run]
  → This is the fix itself. The proposal states it as an output change.
- [A document whose first heading is deeper than a later one, with `--indent 4` or
  more, still gets a code block] → Out of scope (proposal.md - Non-goals). Handling it
  would need a different indent rule than the specs define.
- [awk portability] → Arrays and `END` are POSIX awk and work in gawk, mawk and BWK awk.
  `%*s` is already used today.
