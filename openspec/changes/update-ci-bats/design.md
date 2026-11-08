# Design

## Context

See proposal.md - Why.

`.github/workflows/ci.yml` has one job on `ubuntu-latest`:

```
Setup bats       mig4/setup-bats@v1, bats-version: 1.6.0
Check out code   actions/checkout@v2
Run tests        make test, GH_TOC_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

It runs on `pull_request` and `push` to master, on a schedule twice a week, and by hand
(`workflow_dispatch`).

`bats-core/bats-action@4.1.0` (2026-11-01) is a composite action:

- It downloads the bats-core tarball of `bats-version` from `api.github.com`, with the
  `github-token` input when it is set, and installs it into `~/.local/share/bats`. An
  empty version or `latest` is resolved with the GitHub API to the latest release.
- It caches that directory with `actions/cache` (pinned to the commit of v6.1.0, which
  runs on `node24`). The cache key is
  `${{ runner.os }}-${{ runner.arch }}-bats-${{ inputs.bats-version }}`.
- By default it also installs bats-support, bats-assert, bats-detik and bats-file into
  `/usr/lib/...`.

The tests load only `tests/test_helper.bash`, which has its own `assert_*` functions.
All 76 tests pass locally with bats 1.14.0 (macOS, Homebrew).

`actionlint` 1.7.12 (run with Docker, `rhysd/actionlint`) reports the current `ci.yml`:
`the runner of "actions/checkout@v2" action is too old to run on GitHub Actions`.

## Goals / Non-Goals

**Goals:**

- The same bats version in CI as from Homebrew, set in one place.
- No action in `ci.yml` that targets Node.js 20.

**Non-Goals:**

- Pinning the actions by commit SHA: the workflows of the project use version tags
  (`pages.yml`: `actions/checkout@v7`).

## Decisions

### `bats-core/bats-action` for bats

```
                  bats-action@4.1.0     git clone + install.sh   mig4 with 1.14.0
----------------  --------------------  -----------------------  -----------------
maintained by     bats-core, 2026-11    our own script           no release since 2020
Node.js 20        no (composite)        no                       yes
exact version     bats-version          --branch v1.14.0         bats-version
extra installs    4 libraries, can be   none                     none
                  turned off
cache             yes, key by version   no                       no
```

The action is the official one and was suggested in #176. A `git clone` of the tag with
`install.sh` has no dependency, but is a script of our own to keep in the workflow.
`mig4` with a new version keeps the Node.js 20 warning. npm (`bats` 1.13.0) and apt on
Ubuntu 24.04 (1.10.0) do not have 1.14.0.

### An exact bats version, not `latest`

With an empty version or `latest`, the cache key is always `...-bats-`. The first run
caches the latest bats of that day, and every later run restores it. The scheduled runs
keep the cache in use, so it does not expire, and CI would stay on that bats version.
`bats-version: 1.14.0` gives a key per version: a new version is a one-line change that
also replaces the cache.

### No bats libraries

`support-install`, `assert-install`, `detik-install` and `file-install` are `false`. The
tests do not load them, so they would only add downloads to every run without a cache
hit.

### `github-token`

`github-token: ${{ secrets.GITHUB_TOKEN }}`, the same secret `make test` gets as
`GH_TOC_TOKEN`. Without it, the tarball is downloaded from `api.github.com` without
authentication, which has a limit of 60 requests per hour per IP, shared by the jobs on
the runner's IP.

### `actions/checkout@v7`

v5 moved to `node24` (runner 2.327.1 or newer, GitHub-hosted runners have it), v6 keeps
the credentials in a separate file, v7 blocks checking out a fork PR on
`pull_request_target` and `workflow_run`. `ci.yml` does not use those events, and
`make test` does not use the git credentials. `pages.yml` already uses `@v7`.

### The new steps

```yaml
      - name: Setup bats
        uses: bats-core/bats-action@4.1.0
        with:
          bats-version: 1.14.0
          support-install: false
          assert-install: false
          detik-install: false
          file-install: false
          github-token: ${{ secrets.GITHUB_TOKEN }}

      - name: Check out code
        uses: actions/checkout@v7
```

The step names and their order stay as they are.

### Checks

Locally: `yamllint -d relaxed` and `actionlint` (Docker) on `ci.yml`. The workflow
itself runs only on GitHub: the CI of the PR shows `bats-version: 1.14.0` in the inputs
of "Setup bats", the installed bats, the Node.js 20 annotation without these actions, and
the result of the tests.

## Risks / Trade-offs

- [A test passes with bats 1.6.0 and 1.14.0 on macOS but not with 1.14.0 on Linux] →
  The CI of the PR runs the whole suite before the merge.
- [The remote tests fail now and then on github.com pages] → Not related to this change
  (#179); the failed job can be run again.
- [bats-action changes in a later release] → It is pinned to the `4.1.0` tag.
