# Design

## Context

See proposal.md - Why for the symptoms and specs/toc-heading-markup/spec.md for
requirements.

After the `sed`/`grep` steps of `gh_toc_grab`, every heading is one line of this form,
both in the markdown API output (local file, stdin) and on a remote GitHub page:

```
<h2 class="heading-element">On <sub><sub><a href="#top">Go to Top</a></sub></sub></h2><a id="user-content-on-go-to-top" class="anchor" aria-label="Permalink: On Go to Top" href="#on-go-to-top"><span ...></span></a
```

On a remote page the heading tag has more attributes (`tabindex`, `dir`) and the icon is
an `<svg>`, but the anchor element is the same:
`<a id="user-content-..." class="anchor" aria-label="Permalink: ..." href="#...">`
(checked on the `ekalinin/sitemap.js` README page from the `remote-toc` spec).

The awk script takes:

- the text from the first `">` to the last `</h`, so every tag inside the heading stays;
- the link from the first `href="..."` of the line (`href_regex`), which is the link
  inside the heading text when there is one.

The text and link lines are in each of the two `awkscript` branches (default and
OS/390); the rest of the entry is built in `common_awk_script`, shared by both.

Constraints: BSD awk on macOS (20200816 checked), GNU awk on Linux, the same awk code on
OS/390, `make lint` (shellcheck).

## Goals / Non-Goals

**Goals:**

- Fix both the link and the text inside the existing awk script, without changing the
  `sed`/`grep` steps and without changing entries of headings without tags.

**Non-Goals:**

- A remote test for headings with links: no pinned GitHub page with such headings is
  known. The remote path uses the same awk code and the same anchor element.
- Removing the `<code>` `sed` step that becomes redundant (see below).

## Decisions

### Take the link from the anchor element

Change `href_regex` to `/class="anchor"[^>]*href="[^"]+"/`. In both branches, match it,
keep the matched element, and take the `href` value from inside that element with a
second `match` on `/href="[^"]+"/`. The existing `+`/`%` conversion of `href` in
`common_awk_script` stays as it is.

`[^>]*` keeps the match inside the opening tag of the anchor element. A link inside the
heading text has no `class="anchor"`, so it can not match. The old pattern also had
`+?`, which is not a lazy quantifier in POSIX ERE; the new one uses `+`.

Alternatives considered:

- The last `href` of the line: works on today's markup, but breaks as soon as the icon
  of the anchor gets an `href` (for example an SVG `<use href>`).
- `id="user-content-..."`: needs the prefix removed, and `href` is the value the
  existing `+`/`%` conversion was written for.

### Remove the tags from the text in awk

Add `gsub(/<[^>]*>/, "", text)` to `common_awk_script`, so both branches get it.

It has to be done on `text` in awk, not with a `sed` step over the whole line: such a
step would also remove the anchor element that the link is now taken from.

`<[^>]*>` matches only real tags: GitHub escapes a literal `<` in heading text as `&lt;`
(`## Tom & Jerry <3` gives `Tom &amp; Jerry &lt;3`) and a `>` inside an attribute value
as `&gt;` (`![a>b](x.png)` gives `alt="a&gt;b"`).

Alternatives considered:

- Take the text from `aria-label="Permalink: ..."`, which is GitHub's own plain text of
  the heading: it changes entries of headings without tags (for `# Emoji :rocket: here`
  the text is `Emoji 🚀 here`, the label is `Emoji :rocket: here`) and depends on an
  accessibility attribute.
- Remove only the `<a>` tags: keeps `<em>`, `<sub>` and other inline HTML in entries.
  Not chosen: entries should be plain text.
- Convert the HTML back to markdown (`<em>` to `*`, `<code>` to a backtick): much more
  awk code, and it would also change entries of headings with code (#153).

### Keep the `<code>` and `<g-emoji>` steps

The `sed` step that removes `<code>` and `</code>` is now redundant, but it stays to keep
the diff small. The `<g-emoji>` step must stay: it removes the emoji with its content and
the following space, not only the tags, so without it entries of remote pages with emoji
would change.

### Tests and the comment at the top of the file

- New fixture `tests/test directory/test_headingmarkup.md` with the headings from the
  spec scenario, and a test that asserts every entry and the footer.
- The #145 test runs with `--hide-footer`, which implies `--insert`, so it rewrites
  `test_setextwithformatting.md`. Its assertion and the TOC inside that fixture both
  change to `* [Title two](#title-two)`; otherwise every test run leaves the fixture
  changed.
- Steps 4 and 5 of the comment at the top of `gh-md-toc` describe the text and anchor
  expressions; update them to the new ones.

Checked on a temporary copy of the script with these changes:

- The new fixture gives the entries from the spec scenario.
- `README.md` and every fixture in `tests/test directory/` give byte-for-byte the same
  output as before, except the `Title two` entry of `test_setextwithformatting.md`.
- The four remote pages from the `remote-toc` spec give the same output as before.
- `shellcheck -e SC2008` reports nothing.

## Risks / Trade-offs

- [Existing TOCs with formatted headings change on the next `--insert`] → Stated in
  proposal.md as an output change. Entries of headings without tags do not change.
- [GitHub changes the anchor element (class name or attribute order)] → Every TOC test
  depends on it, so the suite fails right away; the remote tests run on a schedule in CI.
- [A removed element leaves two spaces (`A  B`)] → Accepted: GitHub's own `aria-label`
  has the same two spaces, and markdown shows one space in the rendered link.
