# Proposal

## Why

A heading that contains a link gets a TOC entry that links to the wrong place, and its
text keeps the raw HTML that GitHub renders for the heading (#40, #67). Reproduced with
0.10.0 and the GitHub markdown API:

- `## On <sub><sub>[Go to Top](#top)</sub></sub>` (#40) gives
  `* [On <sub><sub><a href="#top">Go to Top</a></sub></sub>](#top)`: the link goes to
  `#top`, not to `#on-go-to-top`, and the text has a link inside the link of the entry.
- `## [My issue](https://github.com/ekalinin/github-markdown-toc/issues/67)` (#67) gives
  `* [<a href="https://...">My issue</a>](https://github.com/ekalinin/github-markdown-toc/issues/67)`:
  the entry leads away from the document.
- `## See [docs](#top) here` links to `#top`, and `## A ![img](x.png) B` links to
  `x.png`, because GitHub wraps the image in a link.
- `## Linux vs. Samba ***permissions***` keeps `<em><strong>...</strong></em>` in the
  text, but its link is correct.

The link is wrong because the first `href` of the heading line is taken, and a link in
the heading text comes before the heading's own anchor.

## What Changes

- Take the link of every TOC entry from the heading's own anchor (`class="anchor"`), not
  from the first `href` of the line.
- Remove all HTML tags from the heading text, so every entry has the plain text of the
  heading: `* [On Go to Top](#on-go-to-top)`, `* [My issue](#my-issue)`.
- Add a test fixture with headings that have links, an image, formatting and escaped
  characters, and a test for it.
- Update the TOC in the `test_setextwithformatting.md` fixture and the assertion of the
  #145 test from `* [<em>Title two</em>](#title-two)` to `* [Title two](#title-two)`.

Output change: entries of headings with inline formatting or inline HTML (`*em*`,
`**strong**`, `<sub>`, links, images) lose the tags. A TOC that `--insert` put into such
a file changes on the next run. Entries of headings without tags stay byte-for-byte the
same.

Non-goals:

- Decoding HTML entities: `&amp;` and `&lt;` stay as GitHub renders them.
- Collapsing the spaces left by a removed element (`## A ![img](x.png) B` gives `A  B`,
  as in GitHub's own `aria-label`).
- Keeping markdown formatting such as backticks in entries (#153).
- The separate OS/390 awk text regex (`<\/span><\/a>[^<]*<\/h`), which matches an older
  GitHub markup.
- Changes to README, the landing page (`site/`), or `openspec/specs/landing`.
- A version bump.

## Capabilities

### New Capabilities

- `toc-heading-markup`: the link and the text of a TOC entry for a heading that contains
  links, images, formatting or inline HTML, for every input.

### Modified Capabilities

None. `remote-toc` already requires that no entry links to anything other than a
heading anchor of the document; this change makes that true for headings with links.

## Impact

- `gh-md-toc`: the awk script in `gh_toc_grab` (`href_regex`, the `href` line of both
  branches, and `common_awk_script`), plus the steps 4 and 5 of the comment at the top of
  the file. The same awk code runs on OS/390.
- `tests/tests.bats` and `tests/test directory/`: one new fixture and one new test, one
  changed assertion, one changed line in an existing fixture.
- Closes #40 and #67.
