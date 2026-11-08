# Proposal

## Why

CI runs the tests with bats 1.6.0, installed by `mig4/setup-bats@v1` (#176). The latest
bats-core release is 1.14.0 (2026-07-21), and Homebrew installs 1.14.0, so local runs and
CI use different bats versions. All 76 tests pass locally with bats 1.14.0 (macOS).

`mig4/setup-bats` had its last release (`v1.2.0`) in 2020. Every CI run has the warning
`Node.js 20 is deprecated. The following actions target Node.js 20 but are being forced
to run on Node.js 24: actions/checkout@v2, mig4/setup-bats@v1.`

## What Changes

- `.github/workflows/ci.yml`, step "Setup bats": `mig4/setup-bats@v1` with
  `bats-version: 1.6.0` is replaced with `bats-core/bats-action@4.1.0` with
  `bats-version: 1.14.0`. The bats libraries that the action installs by default
  (bats-support, bats-assert, bats-detik, bats-file) are not installed: the tests use
  their own `tests/test_helper.bash`. The action gets `github-token`.
- `.github/workflows/ci.yml`, step "Check out code": `actions/checkout@v2` is replaced
  with `actions/checkout@v7`, the version `pages.yml` already uses.

The tests, `gh-md-toc` and the other workflows do not change.

Non-goals:

- `.github/workflows/dockerimage.yml` (`actions/checkout@v2`,
  `docker/build-push-action@v1`): another workflow, and `docker/build-push-action` has a
  different API in its later versions.
- Taking the latest bats in CI on every run instead of a fixed version.
- Automatic updates of the actions and the bats version (Dependabot).
- The remote tests that fail now and then on github.com pages (#179, the HTTP status of
  a remote URL is not checked).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. The change is in CI only; the behavior of `gh-md-toc` does not change, so
`skip_specs: true` is set in `.openspec.yaml`.

## Impact

- `.github/workflows/ci.yml`: the "Setup bats" and "Check out code" steps.
- CI: bats 1.14.0 instead of 1.6.0, the same version as Homebrew. No Node.js 20 warning
  from this workflow.
- Closes #176.
