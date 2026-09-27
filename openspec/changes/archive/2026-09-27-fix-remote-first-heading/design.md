# Design

## Context

See proposal.md for motivation and specs/remote-toc/spec.md for requirements.

Root cause, checked on the HTML that github.com returns for the pages from #166:

- On a file (blob) page the first heading of the document is on the same physical line
  as the React root of the page (line 786, about 34 KB). Earlier on that line there is
  the file tree pane heading `<h2 class="use-tree-pane-module__Heading...">`, followed
  by a link to `/<owner>/<repo>/tree/<sha>`.
- Every other heading starts on its own line with `<div class="markdown-heading"`.
- `gh_toc_grab` selects headings with `$grepcmd '<h.*class="heading-element".*</a'`.
  With `-o` the match starts at the leftmost `<h` on the line, which is the file tree
  `<h2>`, not the document `<h1>`.
- The awk step then takes the level from the 3rd character (`2`), the text from the
  first `">` to the last `</h` (the page markup), and the first `href` (the tree URL).
  That gives all three symptoms from #166.
- Documents that do not start with a heading, and wiki pages, have nothing but
  whitespace before the first heading tag on its line, so they are not affected.
- The embedded JSON line (785) also contains `heading-element`, but with escaped `<`,
  so the grep does not match it.

Constraints: `grep -Eo` on Linux and macOS/BSD, `pcregrep -o` on OS/390, GNU and BSD
`sed`.

## Goals / Non-Goals

**Goals:**

- Fix remote file pages with a one-line change to the grep pattern, without changing
  the output for local files, stdin, and wiki pages.

**Non-Goals:**

- Restructuring `gh_toc_grab` or making it independent of GitHub page layout.
- An offline test for the remote path: `gh_is_url` accepts only `http*` sources, so a
  saved HTML fixture cannot be fed through `gh_toc_load` without code changes.

## Decisions

### Anchor the grep match at a real heading tag

Change the pattern to `'<h[1-6][^>]*class="heading-element".*</a'`.

`<h[1-6]` accepts only heading tags, and `[^>]*` keeps the match inside that one tag
up to `class="heading-element"`. The leftmost match is then the document heading, so
the awk step gets a line that starts with `<hN ...>`, as it expects. The syntax is the
same for ERE (`grep -E`) and PCRE (`pcregrep`), so the OS/390 branch keeps working
with no separate change.

Checked on a temporary copy of the script:

- Remote: `ekalinin/github-markdown-toc` README, `ekalinin/sitemap.js` README,
  `ekalinin/envirius` README.ru.md are fixed. `the-art-of-command-line` README-zh.md and
  README-pt.md and the `nodeenv` wiki page give the same output as before.
- Local: `README.md` and all 5 fixtures in `tests/test directory/` produce
  byte-for-byte the same output as before.

Alternatives considered:

- Insert a newline before each `<div class="markdown-heading"` with `sed`: a `\n` in
  the replacement is not portable to BSD `sed`.
- Cut the HTML down to `<article class="markdown-body">` before grepping: more code,
  and wiki pages use different markup around the document.
- Read the headings from the embedded JSON (`headerInfo.toc`): exists only on file
  pages, not on wiki pages or API output, and parsing JSON in awk is fragile.

### Re-enable remote tests without changes

The three commented-out remote tests already assert the expected output for pinned
commits. With the fix all three pass as written; with the original script all three
fail. No new tests are added.

## Risks / Trade-offs

- [The trailing `.*</a` is still greedy and runs to the last `</a` on the line] → On
  all checked pages nothing follows the heading anchor on a heading line. Left as is to
  keep the diff minimal; if GitHub adds markup after the heading on the same line, the
  re-enabled remote tests are expected to catch it.
- [Remote tests depend on network access and on github.com markup] → Accepted. They
  use pinned commit URLs, so only a markup change on GitHub's side can break them, and
  CI runs twice a week on a schedule.
