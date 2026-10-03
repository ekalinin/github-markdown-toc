gh-md-toc
=========

[![CI](https://github.com/ekalinin/github-markdown-toc/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/ekalinin/github-markdown-toc/actions/workflows/ci.yml)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/ekalinin/github-markdown-toc)

gh-md-toc — is for you if you **want to generate TOC** (Table Of Content) for a README.md or
a GitHub wiki page **without installing additional software**.

It's my try to fix a problem:

  * [github/issues/215](https://github.com/isaacs/github/issues/215)

gh-md-toc is able to process:

  * stdin
  * local files (markdown files in local file system)
  * remote files (html files on github.com)

gh-md-toc has been used on Ubuntu and macOS. CI currently runs the bats suite on Ubuntu (`ubuntu-latest`) under bash. If you want it on Windows, you
better to use a golang based implementation:

  * [github-markdown-toc.go](https://github.com/ekalinin/github-markdown-toc.go)

It's more solid, reliable and with ability of a parallel processing. And
absolutely without dependencies.

Table of contents
=================

<!--ts-->
* [Installation](#installation)
* [Usage](#usage)
   * [STDIN](#stdin)
   * [Local files](#local-files)
   * [Remote files](#remote-files)
   * [Multiple files](#multiple-files)
   * [Combo](#combo)
   * [Auto insert and update TOC](#auto-insert-and-update-toc)
   * [GitHub token](#github-token)
   * [TOC generation with Github Actions](#toc-generation-with-github-actions)
* [Tests](#tests)
* [Dependency](#dependency)
* [Docker](#docker)
   * [Local](#local)
   * [Public](#public)
<!--te-->


Installation
============

Linux (manual installation)
```bash
$ wget https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc
$ chmod a+x gh-md-toc
```

MacOS (manual installation)
```bash
$ curl https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc -o gh-md-toc
$ chmod a+x gh-md-toc
```

Linux or MacOS (using [Basher](https://github.com/basherpm/basher))
```bash
$ basher install ekalinin/github-markdown-toc
# `gh-md-toc` will automatically be available in the PATH
```

Usage
=====


STDIN
-----

Here's an example of TOC creating for markdown from STDIN:

```bash
➥ cat ~/projects/Dockerfile.vim/README.md | ./gh-md-toc -
* [Dockerfile.vim](#dockerfilevim)
* [Screenshot](#screenshot)
* [Installation](#installation)
         * [Or using Pathogen:](#or-using-pathogen)
         * [Or using Vundle:](#or-using-vundle)
         * [Or using NeoBundle:](#or-using-neobundle)
         * [Or using Vim-Plug](#or-using-vim-plug)
* [License](#license)
```

Local files
-----------

Here's an example of TOC creating for a local README.md:

```bash
➥ ./gh-md-toc ~/projects/Dockerfile.vim/README.md

Table of Contents
=================

* [Dockerfile.vim](#dockerfilevim)
* [Screenshot](#screenshot)
* [Installation](#installation)
         * [Or using Pathogen:](#or-using-pathogen)
         * [Or using Vundle:](#or-using-vundle)
         * [Or using NeoBundle:](#or-using-neobundle)
         * [Or using Vim-Plug](#or-using-vim-plug)
* [License](#license)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
```

To include only headings up to a given level, use `--depth <NUM>`:

```bash
➥ ./gh-md-toc --depth 1 ~/projects/Dockerfile.vim/README.md

Table of Contents
=================

* [Dockerfile.vim](#dockerfilevim)
* [Screenshot](#screenshot)
* [Installation](#installation)
* [License](#license)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
```

To number the entries, use `--numbered list` for an ordered list:

```bash
➥ ./gh-md-toc --numbered list ~/projects/Dockerfile.vim/README.md

Table of Contents
=================

1. [Dockerfile.vim](#dockerfilevim)
1. [Screenshot](#screenshot)
1. [Installation](#installation)
         1. [Or using Pathogen:](#or-using-pathogen)
         1. [Or using Vundle:](#or-using-vundle)
         1. [Or using NeoBundle:](#or-using-neobundle)
         1. [Or using Vim-Plug](#or-using-vim-plug)
1. [License](#license)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
```

or `--numbered outline` for numbers like `3.1.` in the entry text:

```bash
➥ ./gh-md-toc --numbered outline ~/projects/Dockerfile.vim/README.md

Table of Contents
=================

* [1. Dockerfile.vim](#dockerfilevim)
* [2. Screenshot](#screenshot)
* [3. Installation](#installation)
         * [3.1. Or using Pathogen:](#or-using-pathogen)
         * [3.2. Or using Vundle:](#or-using-vundle)
         * [3.3. Or using NeoBundle:](#or-using-neobundle)
         * [3.4. Or using Vim-Plug](#or-using-vim-plug)
* [4. License](#license)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
```

Remote files
------------

And here's an example, when you have a README.md like this:

  * [README.md without TOC](https://github.com/ekalinin/envirius/blob/f939d3b6882bfb6ecb28ef7b6e62862f934ba945/README.md)

And you want to generate TOC for it.

There is nothing easier:

```bash
➥ ./gh-md-toc https://github.com/ekalinin/envirius/blob/master/README.md

Table of Contents
=================

* [envirius](#envirius)
   * [Table of Contents](#table-of-contents)
   * [Idea](#idea)
   * [Features](#features)
* [Installation](#installation)
* [Uninstallation](#uninstallation)
* [Available plugins](#available-plugins)
* [Usage](#usage)
   * [Check available plugins](#check-available-plugins)
   * [Check available versions for each plugin](#check-available-versions-for-each-plugin)
   * [Create an environment](#create-an-environment)
   * [Activate/deactivate environment](#activatedeactivate-environment)
      * [Activating in a new shell](#activating-in-a-new-shell)
      * [Activating in the same shell](#activating-in-the-same-shell)
   * [Get list of environments](#get-list-of-environments)
   * [Get current activated environment](#get-current-activated-environment)
   * [Do something in environment without enabling it](#do-something-in-environment-without-enabling-it)
   * [Export environment into tar archive](#export-environment-into-tar-archive)
   * [Import environment from tar archive](#import-environment-from-tar-archive)
   * [Get help](#get-help)
   * [Get help for a command](#get-help-for-a-command)
* [How to add a plugin?](#how-to-add-a-plugin)
   * [Mandatory elements](#mandatory-elements)
      * [plug_list_versions](#plug_list_versions)
      * [plug_url_for_download](#plug_url_for_download)
      * [plug_build](#plug_build)
   * [Optional elements](#optional-elements)
      * [Variables](#variables)
      * [Functions](#functions)
   * [Examples](#examples)
* [Example of the usage](#example-of-the-usage)
* [Dependencies](#dependencies)
* [Supported OS](#supported-os)
* [Tests](#tests)
* [Version History](#version-history)
* [License](#license)
* [README in another language](#readme-in-another-language)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
```

That's all! Now all you need — is copy/paste result from console into original
README.md.

If you do not want to copy from console you can add `> YOURFILENAME.md` at the end of the command like `./gh-md-toc https://github.com/ekalinin/envirius/blob/master/README.md > table-of-contents.md` and this will store the table of contents to a file named table-of-contents.md in your current folder.

And here is a result:

  * [README.md with TOC](https://github.com/ekalinin/envirius/blob/24ea3be0d3cc03f4235fa4879bb33dc122d0ae29/README.md)

Moreover, it's able to work with GitHub's wiki pages:

```bash
➥ ./gh-md-toc https://github.com/ekalinin/nodeenv/wiki/Who-Uses-Nodeenv

Table of Contents
=================

* [Who Uses Nodeenv?](#who-uses-nodeenv)
   * [edx](#edx)
   * [OpenStack](#openstack)
   * [HSReplay.net](#hsreplaynet)
   * [pre-commit.com](#pre-commitcom)
   * [sailing-channels.com](#sailing-channelscom)
   * [Galaxy](#galaxy)
   * [Lambdas in Python with Serverless.com](#lambdas-in-python-with-serverlesscom)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
```

Multiple files
--------------

It supports multiple files as well:

```bash
➥ ./gh-md-toc \
    https://github.com/bandali/rust-for-c/blob/master/hello_world/README.md \
    https://github.com/bandali/rust-for-c/blob/master/control_flow/README.md \
    https://github.com/bandali/rust-for-c/blob/master/data_types/README.md \
    https://github.com/bandali/rust-for-c/blob/master/unique/README.md

* [Introduction - hello world!](https://github.com/bandali/rust-for-c/blob/master/hello_world/README.md#introduction---hello-world)
            * [1](https://github.com/bandali/rust-for-c/blob/master/hello_world/README.md#1)

* [Control flow](https://github.com/bandali/rust-for-c/blob/master/control_flow/README.md#control-flow)
   * [If](https://github.com/bandali/rust-for-c/blob/master/control_flow/README.md#if)
   * [Loops](https://github.com/bandali/rust-for-c/blob/master/control_flow/README.md#loops)
   * [For loops](https://github.com/bandali/rust-for-c/blob/master/control_flow/README.md#for-loops)
   * [Switch/Match](https://github.com/bandali/rust-for-c/blob/master/control_flow/README.md#switchmatch)
   * [Method call](https://github.com/bandali/rust-for-c/blob/master/control_flow/README.md#method-call)

* [Data types](https://github.com/bandali/rust-for-c/blob/master/data_types/README.md#data-types)
   * [Structs](https://github.com/bandali/rust-for-c/blob/master/data_types/README.md#structs)
   * [Tuples](https://github.com/bandali/rust-for-c/blob/master/data_types/README.md#tuples)
   * [Tuple structs](https://github.com/bandali/rust-for-c/blob/master/data_types/README.md#tuple-structs)
   * [Enums](https://github.com/bandali/rust-for-c/blob/master/data_types/README.md#enums)
   * [Option](https://github.com/bandali/rust-for-c/blob/master/data_types/README.md#option)
   * [Inherited mutabilty and Cell/RefCell](https://github.com/bandali/rust-for-c/blob/master/data_types/README.md#inherited-mutabilty-and-cellrefcell)

* [Unique pointers](https://github.com/bandali/rust-for-c/blob/master/unique/README.md#unique-pointers)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
```

Combo
-----

You can easily combine both ways:

```bash
➥ ./gh-md-toc \
    /home/you/projects/Dockerfile.vim/README.md \
    https://github.com/ekalinin/sitemap.js/blob/master/README.md

* [Dockerfile.vim](/home/you/projects/Dockerfile.vim/README.md#dockerfilevim)
* [Screenshot](/home/you/projects/Dockerfile.vim/README.md#screenshot)
* [Installation](/home/you/projects/Dockerfile.vim/README.md#installation)
         * [Or using Pathogen:](/home/you/projects/Dockerfile.vim/README.md#or-using-pathogen)
         * [Or using Vundle:](/home/you/projects/Dockerfile.vim/README.md#or-using-vundle)
         * [Or using NeoBundle:](/home/you/projects/Dockerfile.vim/README.md#or-using-neobundle)
         * [Or using Vim-Plug](/home/you/projects/Dockerfile.vim/README.md#or-using-vim-plug)
* [License](/home/you/projects/Dockerfile.vim/README.md#license)

* [sitemap <a target="_blank" rel="noopener noreferrer nofollow" href="https://camo.githubusercontent.com/58b74923f31b284091105e7ef6a0a576b1d28fd205d401521cd4eab677a93f39/68747470733a2f2f696d672e736869656c64732e696f2f6e706d2f6c2f736974656d6170"><img src="https://camo.githubusercontent.com/58b74923f31b284091105e7ef6a0a576b1d28fd205d401521cd4eab677a93f39/68747470733a2f2f696d672e736869656c64732e696f2f6e706d2f6c2f736974656d6170" alt="MIT License" data-canonical-src="https://img.shields.io/npm/l/sitemap" style="max-width: 100%;"></a><a href="https://github.com/ekalinin/sitemap.js/actions"><img src="https://github.com/ekalinin/sitemap.js/workflows/Node%20CI/badge.svg" alt="Build Status" style="max-width: 100%;"></a><a target="_blank" rel="noopener noreferrer nofollow" href="https://camo.githubusercontent.com/deabf360f557bbfe69c534282e9498cd62f2bb958708174f4efd6526741e5b44/68747470733a2f2f696d672e736869656c64732e696f2f6e706d2f646d2f736974656d6170"><img src="https://camo.githubusercontent.com/deabf360f557bbfe69c534282e9498cd62f2bb958708174f4efd6526741e5b44/68747470733a2f2f696d672e736869656c64732e696f2f6e706d2f646d2f736974656d6170" alt="Monthly Downloads" data-canonical-src="https://img.shields.io/npm/dm/sitemap" style="max-width: 100%;"></a>](https://github.com/ekalinin/sitemap.js/blob/master/README.mdhttps://camo.githubusercontent.com/58b74923f31b284091105e7ef6a0a576b1d28fd205d401521cd4eab677a93f39/68747470733a2f2f696d672e736869656c64732e696f2f6e706d2f6c2f736974656d6170)
   * [Table of Contents](https://github.com/ekalinin/sitemap.js/blob/master/README.md#table-of-contents)
   * [Installation](https://github.com/ekalinin/sitemap.js/blob/master/README.md#installation)
   * [Generate a one time sitemap from a list of urls](https://github.com/ekalinin/sitemap.js/blob/master/README.md#generate-a-one-time-sitemap-from-a-list-of-urls)
   * [Serve a sitemap from a server and periodically update it](https://github.com/ekalinin/sitemap.js/blob/master/README.md#serve-a-sitemap-from-a-server-and-periodically-update-it)
   * [Create sitemap and index files from one large list](https://github.com/ekalinin/sitemap.js/blob/master/README.md#create-sitemap-and-index-files-from-one-large-list)
      * [Options you can pass](https://github.com/ekalinin/sitemap.js/blob/master/README.md#options-you-can-pass)
   * [Filtering sitemap entries during parsing](https://github.com/ekalinin/sitemap.js/blob/master/README.md#filtering-sitemap-entries-during-parsing)
   * [Examples](https://github.com/ekalinin/sitemap.js/blob/master/README.md#examples)
   * [API](https://github.com/ekalinin/sitemap.js/blob/master/README.md#api)
   * [Maintainers](https://github.com/ekalinin/sitemap.js/blob/master/README.md#maintainers)
   * [License](https://github.com/ekalinin/sitemap.js/blob/master/README.md#license)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
```

Note: the shell expands `~/projects/...` to an absolute path, so the generated links use that absolute path, not `~`.


Auto insert and update TOC
--------------------------

Just put into a file these two lines:

```
<!--ts-->
<!--te-->
```

And run:

```bash
$ ./gh-md-toc --insert README.test.md

Table of Contents
=================

* [Dockerfile.vim](#dockerfilevim)
* [Screenshot](#screenshot)
* [Installation](#installation)
         * [Or using Pathogen:](#or-using-pathogen)
         * [Or using Vundle:](#or-using-vundle)
         * [Or using NeoBundle:](#or-using-neobundle)
         * [Or using Vim-Plug](#or-using-vim-plug)
* [License](#license)
Found markers

!! TOC was added into: 'README.test.md'
!! Origin version of the file: 'README.test.md.orig.2026-10-02_120000'
!! TOC added into a separate file: 'README.test.md.toc.2026-10-02_120000'


<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
```

Now check the same file:

```bash
➜ grep -A20 "<\!--ts" README.test.md
<!--ts-->
* [Dockerfile.vim](#dockerfilevim)
* [Screenshot](#screenshot)
* [Installation](#installation)
         * [Or using Pathogen:](#or-using-pathogen)
         * [Or using Vundle:](#or-using-vundle)
         * [Or using NeoBundle:](#or-using-neobundle)
         * [Or using Vim-Plug](#or-using-vim-plug)
* [License](#license)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: <your-user>, at: Fri Oct  2 12:00:00 UTC 2026 -->

<!--te-->
```

Next time when your file will be changed just repeat the command (`./gh-md-toc
--insert ...`) and TOC will be refreshed again.

GitHub token
------------

All your tokens are [here](https://github.com/settings/tokens).

You will need them if you get an error like this:

```
Parsing local markdown file requires access to github API
Error: You exceeded the hourly limit. See: https://developer.github.com/v3/#rate-limiting
or place github auth token here: ./token.txt
```

A token can be used as an env variable:

```bash
➥ GH_TOC_TOKEN=2a2dab...563 ./gh-md-toc README.md

Table of Contents
=================

* [github\-markdown\-toc](#github-markdown-toc)
* [Table of Contents](#table-of-contents)
* [Installation](#installation)
* [Tests](#tests)
* [Usage](#usage)
* [LICENSE](#license)
```

Or from a file:

```bash
➥ echo "2a2dab...563" > ./token.txt
➥ ./gh-md-toc README.md

Table of Contents
=================

* [github\-markdown\-toc](#github-markdown-toc)
* [Table of Contents](#table-of-contents)
* [Installation](#installation)
* [Tests](#tests)
* [Usage](#usage)
* [LICENSE](#license)
```

TOC generation with Github Actions
----------------------------------

Config:

```yaml
on:
  push:
    branches: [main]
    paths: ['foo.md']

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v7
      - run: |
          curl https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc -o gh-md-toc
          chmod a+x gh-md-toc
          ./gh-md-toc --insert --no-backup --hide-footer foo.md
          rm gh-md-toc
      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: Auto update markdown TOC
```

Tests
=====

Done with [bats](https://github.com/bats-core/bats-core).
Useful articles:

  * https://www.engineyard.com/blog/how-to-use-bats-to-test-your-command-line-tools/
  * http://blog.spike.cx/post/60548255435/testing-bash-scripts-with-bats


How to run tests:

```bash
➥ make test
```

That runs the bats suite (currently 17 tests on `master`). Prefer `make test` over copying a hand-maintained checklist — new cases land often.

Dependency
==========

  * curl or wget
  * awk (mawk is not tested)
  * grep
  * sed
  * bats (for unit tests)

CI runs the bats suite on Ubuntu (`ubuntu-latest`) under bash.

Docker
======

Local
-----

* Build

```shell
$ docker build -t markdown-toc-generator .
```

* Run on an URL

```shell
$ docker run -it markdown-toc-generator https://github.com/ekalinin/envirius/blob/master/README.md
```

* Run on a local file (need to share volume with docker)

```shell
$ docker run -it -v /data/ekalinin/envirius:/data markdown-toc-generator /data/README.md
```

Public
-------

```shell
$ docker pull evkalinin/gh-md-toc:0.10.0

$ docker images | grep toc
evkalinin/gh-md-toc   0.10.0   <image-id>   2024-03-03   ~72MB

$ docker run -it evkalinin/gh-md-toc:0.10.0 \
    https://github.com/ekalinin/envirius/blob/master/README.md
```

The published `0.10.0` image was built in March 2024 from that tag. It does not include later `master` fixes (for example remote first-heading handling from #170) and does not support `--depth`. For current behaviour, build from this repository (`docker build -t markdown-toc-generator .`) or run `./gh-md-toc` locally.
