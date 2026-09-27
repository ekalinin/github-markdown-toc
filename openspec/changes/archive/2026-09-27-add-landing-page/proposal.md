# Proposal

## Why

The project has no web page: GitHub Pages is not enabled
(`https://ekalinin.github.io/github-markdown-toc/` returns 404) and the repository
homepage field is empty. A static one-page site on github.io gives the tool a
landing page that explains what it does, shows how to install and use it, and routes
visitors to the repository.

## What Changes

- Add a static, single-page, English-only site in `site/`, published at
  `https://ekalinin.github.io/github-markdown-toc/`.
- Page content covers seven blocks, based on README but with current facts:
  - A. Why: TOC without installing additional software; link to github/issues/215
  - B. Inputs: stdin, local files, remote files, multiple files. Remote examples use a
    GitHub wiki page URL: for file (blob) URLs the first entry is currently broken
    (#166), so they are not shown until that is fixed
  - C. Auto insert and update TOC (`<!--ts-->` / `<!--te-->` markers, `--insert`)
  - D. GitHub Actions snippet (current major versions of the actions)
  - E. GitHub token (`GH_TOC_TOKEN` / `token.txt`)
  - F. Docker (image tag equal to the current version)
  - G. Windows: link to github-markdown-toc.go
- Current facts instead of README's outdated ones: example output produced by the
  current version (default `--indent 3`), `actions/checkout@v7`,
  `stefanzweifel/git-auto-commit-action@v7`, Docker tag equal to `gh_toc_version`.
  README itself is updated separately in #165.
- Document-style layout with a sidebar table of contents written in gh-md-toc's own
  output format (`* [Title](#anchor)`, 3-space indent per level).
- Syntax highlighting of code blocks by a small inline script: shell, YAML, and TOC
  output (styled like the sidebar). No external resources; without JavaScript the
  blocks stay plain text.
- The displayed version comes from `gh_toc_version` and is substituted at deploy time,
  so the version stays single-sourced.
- Add a GitHub Actions workflow that deploys `site/` to GitHub Pages on pushes to
  `master` that touch the site, `gh-md-toc`, or the workflow itself.
- One-time manual steps after merge: enable Pages with Source "GitHub Actions" and set
  the repository homepage to the page URL.

Non-goals:

- Live in-browser demo or any call to the GitHub API from the page.
- Documentation hub or multiple pages (README stays the documentation).
- Localization, custom domain, analytics, web fonts, CDN, or any other external
  resource.
- Social preview image (`og:image`).
- Changes to README, `gh-md-toc`, tests, `Makefile`, or `ci.yml`.

## Capabilities

### New Capabilities

- `landing`: the project's static landing page on GitHub Pages - content, layout,
  version display, and deployment.

### Modified Capabilities

None.

## Impact

- New files: `site/index.html`, `site/styles.css`, `.github/workflows/pages.yml`.
- Unchanged: `gh-md-toc`, `tests/`, `README.md`, `Makefile`,
  `.github/workflows/ci.yml`, `.github/workflows/dockerimage.yml`.
- Repository settings: GitHub Pages enabled with the GitHub Actions source (creates
  the `github-pages` environment); homepage field set to the page URL.
- `ci.yml` has no path filter, so commits that touch only `site/` still run the bats
  suite. This is accepted and left as is.
