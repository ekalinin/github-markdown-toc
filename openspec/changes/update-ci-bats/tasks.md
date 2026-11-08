# Tasks

## 1. Workflow

- [x] 1.1 `.github/workflows/ci.yml`, step "Setup bats": replace `mig4/setup-bats@v1`
  and `bats-version: 1.6.0` with the `bats-core/bats-action@4.1.0` step from design.md
  (`bats-version: 1.14.0`, the four `*-install: false`, `github-token`); verify
  `yamllint -d relaxed .github/workflows/ci.yml` passes
- [x] 1.2 `.github/workflows/ci.yml`, step "Check out code": replace `actions/checkout@v2`
  with `actions/checkout@v7`; verify
  `docker run --rm -i rhysd/actionlint:1.7.12 -color=false - < .github/workflows/ci.yml`
  reports nothing, and `git diff` changes only these two steps

## 2. Verification

- [x] 2.1 Run `make test` locally with bats 1.14.0 and `GH_TOC_TOKEN` set; verify all
  tests pass
- [x] 2.2 After the branch is pushed and the PR is opened (each step on request), check
  its CI run: "Setup bats" has `bats-version: 1.14.0` in its inputs and installs bats
  1.14.0, the run has no Node.js 20 annotation for `actions/checkout` or the bats step,
  and all tests pass
