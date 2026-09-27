# Design

## Context

See proposal.md for motivation and specs/landing/spec.md for requirements.

Current state that shapes the approach:

- GitHub Pages is not enabled for the repository; there is no `docs/`, no `gh-pages`
  branch, and no user site repository, so the page is a project site under
  `/github-markdown-toc/`.
- The version is single-sourced in `gh_toc_version` (`gh-md-toc`). `make release`
  and the `--version` bats test both depend on it.
- README installs from `master` (`raw.githubusercontent.com/.../master/gh-md-toc`),
  so what a visitor downloads is always master's version.
- Releases are created by hand; `dockerimage.yml` pushes `evkalinin/gh-md-toc:<tag>`
  when a release is published. Docker Hub tags equal the release tags, which equal
  `gh_toc_version`.
- Remote mode is broken for GitHub file URLs (#166); wiki URLs work. Checked with
  0.10.0: `./gh-md-toc README.md https://github.com/ekalinin/nodeenv/wiki/Who-Uses-Nodeenv`
  produces a correct TOC for both inputs.
- `tests/tests.bats` pins README's headings, so README-based example output stays
  valid while the tests pass.

## Goals / Non-Goals

**Goals:**

- No build tooling in the repository: two hand-written files plus one workflow.
- Deployment needs only the default `GITHUB_TOKEN`, with no extra secrets.
- Every version on the page comes from `gh_toc_version`, with no second copy in the
  repository.

**Non-Goals:**

- A local build target in `Makefile`; local preview is a plain static file.
- Automated checks of the page in CI (link checking, HTML validation).
- Automatic refresh of example outputs or action versions shown on the page.

## Decisions

### Deploy through GitHub Actions, not from a branch

The workflow uploads the built `site/` as a Pages artifact and deploys it with
`actions/deploy-pages`.

- Alternative: "Deploy from a branch" with `master:/docs`. Rejected: it serves files
  as-is, so the version would have to be copied into the HTML and bumped by hand,
  which breaks single-sourcing.
- Alternative: a `gh-pages` branch. Rejected: same version problem, and page changes
  would bypass pull requests on `master`.
- Alternative: fetch the version in the browser at runtime. Rejected: an external
  request, which the spec forbids.

### Source folder `site/`

- Alternative: `docs/`. Rejected: implies documentation (README remains the docs)
  and is the folder name for branch-based deploys, which this design does not use.
- Alternative: repository root. Rejected: mixes page files with the tool.

Files: `site/index.html` (content, sidebar, inline copy script) and
`site/styles.css`. No separate JavaScript file: the copy script is a few lines.

### Version substitution at deploy time

`site/index.html` contains the placeholder `{{VERSION}}` (hero, Docker section). The
workflow:

1. `VERSION="$(./gh-md-toc --version | head -n 1)"`
2. copies `site/` to `_site/` and writes `_site/index.html` with
   `sed "s|{{VERSION}}|$VERSION|g" site/index.html > _site/index.html` (a pipe, not
   `sed -i`, to stay portable between GNU and BSD sed when run locally)
3. fails if `grep -n '{{' _site/index.html` finds anything

- Why `--version`: it is the tool's public interface and is covered by the
  `--version` bats test.
- Alternative: parse the `gh_toc_version=` line with a regex. Rejected: it depends on
  the assignment's formatting, and the `Makefile` regex already requires a
  two-digit minor.

### Triggers track `master`, not releases

`on: push` to `master` with `paths: [site/**, gh-md-toc, .github/workflows/pages.yml]`,
plus `workflow_dispatch`. No `pull_request` trigger.

- Why: installation downloads master's `gh-md-toc`, so the page shows the version a
  visitor actually gets. A version bump changes `gh-md-toc` and redeploys the page.
- Alternative: `on: release`. Rejected: between a bump and the release, the page
  would show an older version than the installation commands download.

Workflow settings: `permissions: {contents: read, pages: write, id-token: write}`;
`concurrency: {group: pages, cancel-in-progress: false}`; the deploy job uses the
`github-pages` environment. Actions (checked 2026-09-27): `actions/checkout@v7`,
`actions/configure-pages@v6`, `actions/upload-pages-artifact@v5`,
`actions/deploy-pages@v5`.

### Pages is enabled once by hand

Pages is enabled manually with Source "GitHub Actions" (Settings -> Pages, or
`gh api -X POST repos/ekalinin/github-markdown-toc/pages -f build_type=workflow`).

- Alternative: `configure-pages` with `enablement: true`. Rejected: per its
  `action.yml`, it requires a token other than `GITHUB_TOKEN` (a PAT or GitHub App),
  which would add a secret.

### Page structure and headings

One `h1` and `h2`/`h3` sections, so the sidebar matches gh-md-toc's output for a
markdown document with the same headings:

```
* [gh-md-toc](#gh-md-toc)
   * [Installation](#installation)
   * [Why](#why)
   * [Usage](#usage)
      * [STDIN](#stdin)
      * [Local files](#local-files)
      * [Remote files](#remote-files)
      * [Multiple files](#multiple-files)
   * [Auto insert and update TOC](#auto-insert-and-update-toc)
   * [GitHub Actions](#github-actions)
   * [GitHub token](#github-token)
   * [Docker](#docker)
   * [Windows](#windows)
```

Heading `id`s equal these anchors. The hero is the `h1` "gh-md-toc". Landmarks:
`header` (hero), `nav` (table of contents), `main` (sections), `footer`.

### Sidebar rendering

Each TOC line is one `<a href="#anchor">` rendered with `white-space: pre` in a
monospace font. Its visible text is the full markdown line. The markdown syntax
(`* [`, `](#anchor)`) is wrapped in `<span aria-hidden="true">`, so screen readers
announce only the title.

- Alternative: a nested `<ul>` styled to look like markdown. Rejected: the visible
  text would no longer be the tool's literal output.

### Example inputs

Outputs are captured by running 0.10.0 at implementation time:

| Section        | Command                                                                          |
|----------------|----------------------------------------------------------------------------------|
| STDIN          | `cat README.md \| ./gh-md-toc -`                                                  |
| Local files    | `./gh-md-toc README.md`                                                          |
| Remote files   | `./gh-md-toc https://github.com/ekalinin/nodeenv/wiki/Who-Uses-Nodeenv`          |
| Multiple files | `./gh-md-toc README.md https://github.com/ekalinin/nodeenv/wiki/Who-Uses-Nodeenv` |
| Auto insert    | `./gh-md-toc --insert` on a scratch file with the two markers                     |
| Docker (URL)   | `docker run ... evkalinin/gh-md-toc:{{VERSION}} <the wiki URL>`                  |

README output is pinned by the bats tests. Long outputs are shortened with a `...`
line.

### GitHub Actions snippet

Based on README's snippet, updated to `actions/checkout@v7` and
`stefanzweifel/git-auto-commit-action@v7`, with job-level
`permissions: contents: write`. The action's README documents this as required for
the default `GITHUB_TOKEN`.

### Styling

`styles.css` uses system font stacks: sans-serif for prose, monospace for code and the
sidebar. Colors are CSS custom properties with a light default and a
`@media (prefers-color-scheme: dark)` override. Layout is a two-column CSS grid with a
sticky sidebar. Below a breakpoint it becomes a single column with the TOC first.
`pre` blocks use `overflow-x: auto`, and there are visible `:focus-visible` outlines.

### Copy buttons

An inline script at the end of `body` adds a button to every `pre` marked
`data-copy`. The button copies the block's text with `navigator.clipboard.writeText`.
Copyable blocks contain commands only, with no `$` prompt, so the copied text is the
visible text. Blocks with command output are not marked. Because the buttons are
created by the script, no-JS visitors see no dead buttons.

### Syntax highlighting

A small regex-based highlighter in the same inline script. Each `pre` declares its
kind with `data-lang`:

| `data-lang` | Blocks                                    | Highlighted                                              |
|-------------|-------------------------------------------|----------------------------------------------------------|
| `sh`        | command-only blocks (Installation, token, Docker) | command names, flags, quoted strings                |
| `console`   | `$ command` + output (Usage, Auto insert) | first line as `sh` with a muted `$`; the rest as `output` |
| `yaml`      | GitHub Actions snippet                    | keys, quoted strings, comments                           |
| `output`    | markers, file contents                    | TOC lines like the sidebar, HTML comments muted          |

The script reads `code.textContent`, escapes it, wraps tokens in `<span class="tok-*">`,
and writes it back, so the text is unchanged: copy buttons, the example checks, and
`{{VERSION}}` substitution work as before. Blocks without `data-lang` stay plain.
Colors reuse `--muted` and `--accent`, plus two new custom properties for strings and
flags, with light and dark values.

- Alternative: vendored Prism.js. Rejected: a ~20 KB third-party file to keep up to
  date, and it would not style TOC output like the sidebar.
- Alternative: static `<span>` markup in the HTML. Rejected: works without JS, but
  every example edit would need hand-written markup.

## Risks / Trade-offs

- [After a version bump is merged, the Docker section names a tag that Docker Hub
  gets only when the release is published] -> Publish the release right after the
  bump; the gap is accepted.
- [Example outputs go stale if GitHub changes its HTML or the wiki page changes] ->
  README-based outputs are guarded by the bats tests; re-capture the wiki outputs
  whenever the page is edited or a release changes output.
- [Action versions in the snippet age] -> Update them when the page is touched; no
  automation.
- [The first deploy fails if Pages is not enabled yet] -> Enable Pages before merging;
  otherwise enable it and re-run through `workflow_dispatch`.
- [Once #166 is fixed, the page still avoids file URLs] -> A follow-up change can add
  a `/blob/` example and drop the requirement "No GitHub file URLs in examples".
- [Every change to `gh-md-toc` redeploys the page, not only version bumps] ->
  Harmless: the deploy is idempotent and takes under a minute.

## Migration Plan

1. Before merge: enable Pages with Source "GitHub Actions".
2. Merge the PR into `master`; the push triggers the first deploy.
3. Verify `https://ekalinin.github.io/github-markdown-toc/` returns 200 and shows
   `v0.10.0`.
4. Set the repository homepage to the page URL.

Rollback: revert the merge commit and disable Pages (Settings -> Pages, or
`gh api -X DELETE repos/ekalinin/github-markdown-toc/pages`). The tool, its tests, and
the Docker image are not affected either way.

## Open Questions

- Exact palette and accent color: chosen during implementation within the WCAG AA
  requirement.
