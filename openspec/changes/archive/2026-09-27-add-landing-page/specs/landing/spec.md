# Spec Delta

## Purpose

A static one-page landing site for gh-md-toc on GitHub Pages that explains what the
tool does, shows how to install and use it with current facts, and routes visitors to
the repository.

## ADDED Requirements

### Requirement: Published location

The landing page SHALL be served at `https://ekalinin.github.io/github-markdown-toc/`
from the latest successful deployment of the `master` branch.

#### Scenario: Page is reachable after deployment
- **WHEN** a deployment of `master` has completed
- **THEN** a GET request to `https://ekalinin.github.io/github-markdown-toc/` returns
  HTTP 200 with the landing page

### Requirement: Single static English page

The site SHALL consist of one HTML page in English. All text, code examples, and
navigation SHALL be present in the HTML itself, so the page is fully readable and
navigable with JavaScript disabled.

#### Scenario: JavaScript disabled
- **WHEN** the page is opened in a browser with JavaScript disabled
- **THEN** every section, code example, and navigation link is visible and works

### Requirement: No external resources

The page SHALL NOT load any resource from another origin: no scripts, stylesheets,
fonts, images, or analytics. Outbound links to other sites are allowed.

#### Scenario: Network requests stay on the page origin
- **WHEN** the page is loaded with the browser's network inspector open
- **THEN** every request goes to `ekalinin.github.io`

### Requirement: Page metadata

The page SHALL define a `<title>`, a meta description, `og:title`, `og:description`,
`og:url`, and a canonical link pointing to the published URL. The page SHALL NOT
define `og:image`.

#### Scenario: Link preview uses page metadata
- **WHEN** the page URL is inspected by a link-preview tool
- **THEN** the preview shows the page title and description and no image

### Requirement: Hero

The page SHALL start with the project name `gh-md-toc`, the repository description
"Easy TOC creation for GitHub README.md", the current version prefixed with `v`, and
a link to `https://github.com/ekalinin/github-markdown-toc`.

#### Scenario: Hero shows the current version
- **WHEN** the deployed commit has `gh_toc_version="0.10.0"` in `gh-md-toc`
- **THEN** the hero shows `v0.10.0`

### Requirement: Sections and order

After the hero, the page SHALL contain these sections in this order: Installation,
Why, Usage (with subsections STDIN, Local files, Remote files, Multiple files), Auto
insert and update TOC, GitHub Actions, GitHub token, Docker, Windows. A footer SHALL
link to the repository and to its MIT license.

#### Scenario: Reading the page top to bottom
- **WHEN** a visitor scrolls from the top of the page to the bottom
- **THEN** the sections appear in the order listed above, followed by the footer

### Requirement: Installation section

The Installation section SHALL show manual download of
`https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc`
with `curl` and with `wget`, each followed by `chmod a+x gh-md-toc`, and installation
with Basher (`basher install ekalinin/github-markdown-toc`).

#### Scenario: Manual installation with curl
- **WHEN** a visitor runs the curl commands from the Installation section on Linux or
  macOS
- **THEN** an executable `gh-md-toc` appears in the current directory and
  `./gh-md-toc --version` prints the version shown in the hero

### Requirement: Why section

The Why section SHALL state that gh-md-toc generates a TOC for a README.md or a GitHub
wiki page without installing additional software, list the tools it needs (curl or
wget, awk, grep, sed), and link to `https://github.com/isaacs/github/issues/215`.

#### Scenario: Visitor checks requirements
- **WHEN** a visitor reads the Why section
- **THEN** they see the list of required tools and the link to the original GitHub
  issue

### Requirement: Examples reflect the current version

Every command example that shows output (Usage subsections and Auto insert and update
TOC) SHALL show output produced by running that command with the version shown on the
page. A shortened output SHALL keep its shown lines verbatim and mark the cut with a
line containing `...`.

#### Scenario: Reproducing an example
- **WHEN** a visitor runs an example command with the version shown on the page
- **THEN** the output matches the output shown on the page, up to any `...` cut

#### Scenario: Current indentation
- **WHEN** an example output contains nested entries
- **THEN** top-level entries have no indent and each nested level adds 3 spaces

### Requirement: No GitHub file URLs in examples

While issue #166 (broken first entry for GitHub file URLs) is open, no example on the
page SHALL use a GitHub file (`/blob/`) URL. Remote examples SHALL use a GitHub wiki
page URL instead.

#### Scenario: Remote files example
- **WHEN** a visitor reads the Remote files, Multiple files, or Docker examples
- **THEN** every remote input is a GitHub wiki page URL, and none contains `/blob/`

### Requirement: Auto insert and update TOC section

The section SHALL show the `<!--ts-->` and `<!--te-->` markers, the `--insert`
command with its output as printed by the current version, and describe the
`--no-backup` and `--hide-footer` options.

#### Scenario: Visitor sets up auto insert
- **WHEN** a visitor adds the two markers to a local markdown file and runs the shown
  `--insert` command
- **THEN** the TOC is written between the markers and the printed messages match the
  ones shown on the page

### Requirement: GitHub Actions section

The section SHALL show a workflow snippet that downloads gh-md-toc, runs
`./gh-md-toc --insert --no-backup --hide-footer` on a markdown file, and commits the
result. The snippet SHALL use `actions/checkout@v7` and
`stefanzweifel/git-auto-commit-action@v7` and SHALL grant the permissions the commit
step needs under the default read-only `GITHUB_TOKEN`.

#### Scenario: Snippet works in a new repository
- **WHEN** a visitor copies the snippet into a repository with default workflow
  permissions and pushes a change to the watched markdown file
- **THEN** the workflow updates the TOC and commits it back

### Requirement: GitHub token section

The section SHALL explain that a token is read from the `GH_TOC_TOKEN` environment
variable or from a `token.txt` file next to the script, link to
`https://github.com/settings/tokens`, and show the rate-limit error message as printed
by the current version.

#### Scenario: Visitor hits the rate limit
- **WHEN** a visitor sees the rate-limit error from gh-md-toc
- **THEN** the same message is shown in the GitHub token section, next to both ways of
  passing a token

### Requirement: Docker section

The section SHALL show pulling and running `evkalinin/gh-md-toc:<version>`, where
`<version>` equals the version shown in the hero, and building and running the image
locally from the repository's `Dockerfile`, both on a URL and on a local file mounted
as a volume.

#### Scenario: Docker tag follows the version
- **WHEN** the deployed commit has `gh_toc_version="0.10.0"`
- **THEN** the Docker section shows `evkalinin/gh-md-toc:0.10.0`

### Requirement: Windows section

The Windows section SHALL point Windows users to
`https://github.com/ekalinin/github-markdown-toc.go`.

#### Scenario: Windows visitor
- **WHEN** a Windows user reads the Windows section
- **THEN** they find a link to github-markdown-toc.go

### Requirement: Version is single-sourced

Every version shown on the page SHALL equal `gh_toc_version` in `gh-md-toc` at the
deployed commit. A deployment SHALL fail, leaving the previous deployment live, if any
version placeholder remains unsubstituted.

#### Scenario: Version bump
- **WHEN** a commit that changes `gh_toc_version` from `0.10.0` to `0.11.0` is pushed
  to `master`
- **THEN** after the resulting deployment the hero shows `v0.11.0` and the Docker
  section shows `evkalinin/gh-md-toc:0.11.0`

#### Scenario: Unsubstituted placeholder
- **WHEN** the built page still contains a version placeholder
- **THEN** the deployment fails and the previously deployed page stays online

### Requirement: Table of contents in gh-md-toc format

The page SHALL have a table of contents whose lines are exactly the entry lines that
gh-md-toc produces for a markdown document with the page's headings at the same
levels: `* [Title](#anchor)`, with 3 spaces of indent per level below the first. Each
entry SHALL link to its section, and each section's anchor SHALL equal the anchor
GitHub generates for that heading.

#### Scenario: Entry format and navigation
- **WHEN** the page has a level-2 heading "Auto insert and update TOC"
- **THEN** the table of contents contains the line
  `   * [Auto insert and update TOC](#auto-insert-and-update-toc)`, and activating it
  moves to that section

#### Scenario: Matches the tool's own output
- **WHEN** the page's headings are written as a markdown document at the same levels
  and passed to gh-md-toc
- **THEN** the entry lines of its output equal the lines of the page's table of
  contents

### Requirement: Responsive document layout

On wide screens the table of contents SHALL be shown in a sidebar next to the content.
On narrow screens it SHALL be shown above the content. Code blocks SHALL scroll
horizontally instead of overflowing the page.

#### Scenario: Wide screen
- **WHEN** the page is viewed on a desktop-width window
- **THEN** the table of contents is a sidebar next to the content

#### Scenario: Narrow screen
- **WHEN** the page is viewed on a phone-width window
- **THEN** the table of contents appears above the content and the page does not
  scroll horizontally

### Requirement: Color scheme follows the system

The page SHALL use a light or dark color scheme according to the visitor's system
preference (`prefers-color-scheme`), with no manual toggle. Text SHALL meet WCAG AA
contrast in both schemes.

#### Scenario: Dark system theme
- **WHEN** the visitor's system uses a dark theme
- **THEN** the page renders in its dark scheme

### Requirement: Copy buttons

Command-only blocks (Installation, GitHub Actions snippet, Docker commands) SHALL have
a copy button that copies text runnable as-is: no prompt characters and no output
lines. Without JavaScript the buttons SHALL NOT be shown.

#### Scenario: Copying installation commands
- **WHEN** a visitor clicks the copy button of the curl installation block
- **THEN** the clipboard contains the curl and chmod commands without a leading `$`

#### Scenario: No JavaScript
- **WHEN** the page is opened with JavaScript disabled
- **THEN** no copy buttons are shown

### Requirement: Syntax highlighting

With JavaScript enabled, code blocks SHALL be highlighted: in shell commands the
prompt, command names, flags, and quoted strings; in YAML the keys, strings, and
comments; in TOC output the markdown syntax muted and the titles in the accent color,
as in the table of contents; HTML comments muted. Highlighting SHALL NOT change the
text of any block and SHALL NOT load external resources. Without JavaScript the
blocks SHALL be shown as plain text. Highlight colors SHALL meet WCAG AA contrast in
both color schemes.

#### Scenario: Shell command
- **WHEN** the curl installation block is shown with JavaScript enabled
- **THEN** `curl` and `chmod` are highlighted as commands and `-o` as a flag

#### Scenario: TOC output
- **WHEN** an example output contains the line `   * [STDIN](#stdin)`
- **THEN** `* [` and `](#stdin)` are muted and `STDIN` is in the accent color

#### Scenario: Text is unchanged
- **WHEN** highlighting has been applied
- **THEN** the text of every code block equals its text in the HTML source, and copy
  buttons copy the same text as before

#### Scenario: No JavaScript
- **WHEN** the page is opened with JavaScript disabled
- **THEN** code blocks are shown as plain text

### Requirement: Deployment triggers

The page SHALL be deployed on pushes to `master` that change files under `site/`,
`gh-md-toc`, or the deployment workflow, and on manual dispatch. Other pushes and
pull requests SHALL NOT deploy.

#### Scenario: Unrelated change
- **WHEN** a commit that changes only `tests/` is pushed to `master`
- **THEN** no deployment runs

#### Scenario: Pull request
- **WHEN** a pull request that changes `site/` is opened
- **THEN** no deployment runs
