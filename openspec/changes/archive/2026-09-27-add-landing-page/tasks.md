# Tasks

## 1. Setup

- [x] 1.1 Create branch `feat/landing-page` from `master` and verify `git branch --show-current` prints `feat/landing-page`

## 2. Page skeleton

- [x] 2.1 Create `site/index.html` with `<head>` metadata (title, meta description, `og:title`, `og:description`, `og:url`, canonical link to `https://ekalinin.github.io/github-markdown-toc/`, stylesheet `styles.css`) and the landmarks `header`, `nav`, `main`, `footer`; verify every tag is present and `grep -c 'og:image' site/index.html` prints `0`
- [x] 2.2 Add the hero: `h1` "gh-md-toc" with `id="gh-md-toc"`, the description "Easy TOC creation for GitHub README.md", `v{{VERSION}}`, and a link to the repository; verify the placeholder appears in the hero
- [x] 2.3 Add the `h2`/`h3` section headings with `id`s from design.md "Page structure and headings", in the order from the spec; verify the list of `id`s extracted with grep equals the anchors in design.md
- [x] 2.4 Add the `nav` table of contents: one `<a>` per line with `white-space: pre` text in gh-md-toc format and the markdown syntax wrapped in `<span aria-hidden="true">`; verify each link targets an existing `id` (full check in 6.1)
- [x] 2.5 Add the footer with links to the repository and its MIT `LICENSE`; verify both links open the right pages

## 3. Content

- [x] 3.1 Installation: curl + chmod, wget + chmod, and Basher blocks, marked `data-copy`, without `$` prompts; verify the commands match README's Installation section
- [x] 3.2 Why: the "without installing additional software" statement for README.md and wiki pages, the tool list (curl or wget, awk, grep, sed), and the link to `https://github.com/isaacs/github/issues/215`; verify the link resolves
- [x] 3.3 STDIN and Local files: run `cat README.md | ./gh-md-toc -` and `./gh-md-toc README.md` with 0.10.0 and paste the commands and outputs verbatim (shorten with a `...` line if needed); verify the shown lines equal the README assertions in `tests/tests.bats`
- [x] 3.4 Remote files and Multiple files: run `./gh-md-toc https://github.com/ekalinin/nodeenv/wiki/Who-Uses-Nodeenv` and `./gh-md-toc README.md https://github.com/ekalinin/nodeenv/wiki/Who-Uses-Nodeenv` and paste commands and outputs verbatim; verify no `<pre>` block on the page contains `/blob/`
- [x] 3.5 Auto insert and update TOC: in a temp dir (`mktemp -d`), create a file with `<!--ts-->` / `<!--te-->`, run `--insert`, and paste the markers, the command, its messages, and the resulting block; describe `--no-backup` and `--hide-footer`; verify the messages match `gh-md-toc` lines 207-210
- [x] 3.6 GitHub Actions: README's snippet with `actions/checkout@v7`, `stefanzweifel/git-auto-commit-action@v7`, and job-level `permissions: contents: write`, marked `data-copy`; verify it parses as YAML and matches the permissions shown in the action's README
- [x] 3.7 GitHub token: `GH_TOC_TOKEN` and `token.txt` usage, the link to `https://github.com/settings/tokens`, and the rate-limit message; verify the message text equals `gh-md-toc` lines 163-164
- [x] 3.8 Docker: `docker pull` / `docker run` of `evkalinin/gh-md-toc:{{VERSION}}` on the wiki URL, plus local `docker build` and `docker run` on the wiki URL and on a mounted local file, command blocks marked `data-copy`; verify both commands use `{{VERSION}}` and no block contains `/blob/`
- [x] 3.9 Windows: a link to `https://github.com/ekalinin/github-markdown-toc.go`; verify the link resolves

## 4. Styles and behavior

- [x] 4.1 Create `site/styles.css`: system font stacks (sans for prose, mono for code and the sidebar), color custom properties with a light default and a `prefers-color-scheme: dark` override, a two-column grid with a sticky sidebar, a single column with the TOC first below the breakpoint, `pre { overflow-x: auto }`, and `:focus-visible` outlines; verify in a browser at desktop width and at 375px that the page does not scroll horizontally
- [x] 4.2 Pick the palette and verify every text/background pair meets WCAG AA (at least 4.5:1) in both schemes with a contrast checker
- [x] 4.3 Add the inline copy script that adds a button to each `pre[data-copy]` and copies its text with `navigator.clipboard.writeText`; verify that clicking the curl block's button puts the commands without `$` in the clipboard
- [x] 4.4 Mark every code block with `data-lang` (`sh`, `console`, `yaml`, `output`) per design.md "Syntax highlighting"; verify each `pre` except the rate-limit message has one
- [x] 4.5 Add the highlighter to the inline script and the `tok-*` styles with two new color properties (strings, flags) for both schemes; verify in the browser that `curl`/`chmod` are commands, `-o` is a flag, and `   * [STDIN](#stdin)` has muted syntax and an accent title
- [x] 4.6 Verify that after highlighting every block's `textContent` equals the source text, the copy buttons still copy the same text, blocks are plain with JavaScript disabled, and the new colors meet WCAG AA in both schemes

## 5. Deploy workflow

- [x] 5.1 Create `.github/workflows/pages.yml`: `push` to `master` with `paths: [site/**, gh-md-toc, .github/workflows/pages.yml]`, `workflow_dispatch`, permissions `contents: read`, `pages: write`, `id-token: write`, concurrency group `pages` without cancel, steps `actions/checkout@v7`, `actions/configure-pages@v6`, version from `./gh-md-toc --version | head -n 1`, copy `site/` to `_site/` with `sed` substitution of `{{VERSION}}`, a `grep '{{'` guard, `actions/upload-pages-artifact@v5` with `path: _site`, and `actions/deploy-pages@v5` in the `github-pages` environment; verify the file parses as YAML (and passes `actionlint` if it is installed)
- [x] 5.2 Run the workflow's build commands locally into a temp dir; verify the result contains `v0.10.0` and `evkalinin/gh-md-toc:0.10.0` and no `{{`
- [x] 5.3 Run the guard on the unsubstituted `site/index.html`; verify it exits non-zero

## 6. Verification

- [x] 6.1 Write the page's headings as a markdown file at the same levels in a temp dir, run `./gh-md-toc` on it, and compare its entry lines with the sidebar's text; verify they are identical
- [x] 6.2 Serve the built page locally (`python3 -m http.server`) and open it with the network inspector; verify every request stays on the page's origin
- [x] 6.3 Open the built page with JavaScript disabled; verify all sections and TOC links work and no copy buttons are shown
- [x] 6.4 Verify `make test` passes in CI on the PR (`ci.yml` runs it on pull requests; bats is not installed locally), and run `make lint`; verify its output is identical to `master` (the tool is unchanged; the existing warnings are tracked in #167)
- [x] 6.5 Run `openspec validate add-landing-page --strict`; verify it reports the change as valid

## 7. Delivery (each outward step needs the user's confirmation)

- [x] 7.1 Commit `site/` and `.github/workflows/pages.yml` as `feat(landing): add GitHub Pages landing page` (whether to commit `openspec/` is the user's call); verify with `git log -1 --stat`
- [x] 7.2 Push `feat/landing-page` as a separate command and open a PR to `master`; verify the PR URL
- [x] 7.3 Enable Pages with Source "GitHub Actions" (Settings -> Pages, or `gh api -X POST repos/ekalinin/github-markdown-toc/pages -f build_type=workflow`); verify `gh api repos/ekalinin/github-markdown-toc/pages --jq .build_type` prints `workflow`
- [x] 7.4 After the merge, check the deploy run; verify it succeeded, `https://ekalinin.github.io/github-markdown-toc/` returns 200, and the hero shows `v0.10.0`
- [x] 7.5 Set the repository homepage with `gh repo edit ekalinin/github-markdown-toc --homepage https://ekalinin.github.io/github-markdown-toc/`; verify `gh repo view --json homepageUrl` shows the URL
