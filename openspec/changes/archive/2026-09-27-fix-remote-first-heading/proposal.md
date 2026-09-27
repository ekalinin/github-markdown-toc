# Proposal

## Why

For a GitHub file (`/blob/`) URL whose document starts with a heading, the first TOC
entry is replaced with about 30 KB of GitHub page markup, indented as a second-level
entry, with a link to the repository tree instead of the heading anchor (#166).
Reproduced with 0.10.0 on `ekalinin/github-markdown-toc` README, `ekalinin/sitemap.js`
README and `ekalinin/envirius` README.ru.md. Wiki pages and documents that do not start
with a heading are not affected.

## What Changes

- Fix the heading grep in `gh_toc_grab` so a match can start only at a real
  `<h1>`..`<h6>` heading tag, not at any earlier `<h...` tag on the same line of the
  page.
- Re-enable the three commented-out remote tests in `tests/tests.bats` as they are
  written:
  - `TOC for remote README.md`
  - `TOC for mixed README.md (remote/local)`
  - `TOC for remote non-english chars (remote load), #6, #10`

Non-goals:

- Changes to the local file and stdin paths (output stays byte-for-byte the same).
- The separate OS/390 awk text regex (`<\/span><\/a>[^<]*<\/h`), which matches an
  older GitHub markup.
- Changes to README, the landing page (`site/`), or `openspec/specs/landing`.
- A version bump.

## Capabilities

### New Capabilities

- `remote-toc`: TOC generation for remote GitHub pages (file and wiki URLs).

### Modified Capabilities

None.

## Impact

- `gh-md-toc`: one line in `gh_toc_grab` (the `$grepcmd` pattern). The same pattern is
  used by `grep -Eo` and by `pcregrep -o` on OS/390.
- `tests/tests.bats`: three tests uncommented. They fetch pages from github.com, so the
  suite depends on network access and on GitHub page markup. They were commented out
  in `9618358` ("commented out some tests (with remote logic)").
- `openspec/specs/landing` has the requirement "No GitHub file URLs in examples",
  which applies only while #166 is open. This change does not touch it.
