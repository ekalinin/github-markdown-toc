# remote-toc Specification

## Purpose

Generates a table of contents for a remote GitHub page (a file or a wiki page) given by
its URL, with anchors identical to the ones GitHub renders for that page.

## Requirements

### Requirement: TOC for a remote GitHub page

For a GitHub file (`/blob/`) URL or a GitHub wiki page URL, the TOC SHALL contain one
entry per heading of the rendered document, in document order, including the first
heading when the document starts with a heading. Each entry SHALL have the form
`* [<heading text>](#<anchor>)`, indented by `(level - 1) * indent` spaces (indent is
3 by default). No entry SHALL contain markup of the GitHub page around the document or
link to anything other than a heading anchor of the document.

#### Scenario: File that starts with a heading

- **WHEN** the user runs `gh-md-toc https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md`
- **THEN** the output is `Table of Contents`, `=================`,
  `* [sitemap.js](#sitemapjs)`, `   * [Installation](#installation)`,
  `   * [Usage](#usage)`, `   * [License](#license)`, and
  `<!-- Created by https://github.com/ekalinin/github-markdown-toc -->` (ignoring empty
  lines)

#### Scenario: File with non-English headings

- **WHEN** the user runs `gh-md-toc https://github.com/ekalinin/envirius/blob/f939d3b6882bfb6ecb28ef7b6e62862f934ba945/README.ru.md`
- **THEN** the first entries are `* [envirius](#envirius)`, `   * [Идея](#идея)`,
  `   * [Особенности](#особенности)`, `* [Установка](#установка)`

#### Scenario: File that does not start with a heading

- **WHEN** the user runs `gh-md-toc https://github.com/jlevy/the-art-of-command-line/blob/217da3b4fa751014ecc122fd9fede2328a7eeb3e/README-pt.md`
- **THEN** the first entries are
  `* [A arte da linha de comando](#a-arte-da-linha-de-comando)`, `   * [Meta](#meta)`,
  `   * [Básico](#básico)`, `   * [Uso diário](#uso-diário)`

#### Scenario: Wiki page

- **WHEN** the user runs `gh-md-toc https://github.com/ekalinin/nodeenv/wiki/Who-Uses-Nodeenv`
- **THEN** the first entries are `* [Who Uses Nodeenv?](#who-uses-nodeenv)`,
  `   * [edx](#edx)`, `   * [OpenStack](#openstack)`

### Requirement: Remote page among multiple inputs

When more than one input is given, the entries of a remote page SHALL follow the same
rules, with each link prefixed by the page URL: `* [<heading text>](<URL>#<anchor>)`.

#### Scenario: Local file and remote file

- **WHEN** the user runs `gh-md-toc README.md https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md`
- **THEN** the README entries are followed by
  `* [sitemap.js](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#sitemapjs)`,
  `   * [Installation](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#installation)`,
  `   * [Usage](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#usage)`,
  `   * [License](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#license)`
