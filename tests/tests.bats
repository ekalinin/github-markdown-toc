#!/usr/bin/env bats

load test_helper


@test "TOC for local README.md" {
    run $BATS_TEST_DIRNAME/../gh-md-toc README.md
    assert_success

    assert_equal "${lines[0]}"  "Table of Contents"
    assert_equal "${lines[1]}"  "================="
    assert_equal "${lines[2]}"  "  * [gh-md-toc](#gh-md-toc)"
    assert_equal "${lines[3]}"  "  * [Table of contents](#table-of-contents)"
    assert_equal "${lines[4]}"  "  * [Installation](#installation)"
    assert_equal "${lines[5]}"  "  * [Usage](#usage)"
    assert_equal "${lines[6]}"  "    * [STDIN](#stdin)"
    assert_equal "${lines[7]}"  "    * [Local files](#local-files)"
    assert_equal "${lines[8]}"  "    * [Remote files](#remote-files)"
    assert_equal "${lines[9]}"  "    * [Multiple files](#multiple-files)"
    assert_equal "${lines[10]}" "    * [Combo](#combo)"
    assert_equal "${lines[11]}" "  * [Tests](#tests)"
    assert_equal "${lines[12]}" "  * [Dependency](#dependency)"
    assert_equal "${lines[13]}" "Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)"

}

@test "TOC for remote README.md" {
    run $BATS_TEST_DIRNAME/../gh-md-toc https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md
    assert_success

    assert_equal "${lines[0]}"  "Table of Contents"
    assert_equal "${lines[1]}"  "================="
    assert_equal "${lines[2]}"  "  * [sitemap.js](#sitemapjs)"
    assert_equal "${lines[3]}"  "    * [Installation](#installation)"
    assert_equal "${lines[4]}"  "    * [Usage](#usage)"
    assert_equal "${lines[5]}"  "    * [License](#license)"
    assert_equal "${lines[6]}"  "Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)"
}

@test "TOC for mixed README.md (remote/local)" {
    run $BATS_TEST_DIRNAME/../gh-md-toc \
        README.md \
        https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md
    assert_success

    assert_equal "${lines[0]}"   "  * [gh-md-toc](README.md#gh-md-toc)"
    assert_equal "${lines[1]}"   "  * [Table of contents](README.md#table-of-contents)"
    assert_equal "${lines[2]}"   "  * [Installation](README.md#installation)"
    assert_equal "${lines[3]}"   "  * [Usage](README.md#usage)"
    assert_equal "${lines[4]}"   "    * [STDIN](README.md#stdin)"
    assert_equal "${lines[5]}"   "    * [Local files](README.md#local-files)"
    assert_equal "${lines[6]}"   "    * [Remote files](README.md#remote-files)"
    assert_equal "${lines[7]}"   "    * [Multiple files](README.md#multiple-files)"
    assert_equal "${lines[8]}"   "    * [Combo](README.md#combo)"
    assert_equal "${lines[9]}"   "  * [Tests](README.md#tests)"
    assert_equal "${lines[10]}"  "  * [Dependency](README.md#dependency)"
    assert_equal "${lines[11]}"  "  * [sitemap.js](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#sitemapjs)"
    assert_equal "${lines[12]}"  "    * [Installation](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#installation)"
    assert_equal "${lines[13]}"  "    * [Usage](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#usage)"
    assert_equal "${lines[14]}"  "    * [License](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#license)"
    assert_equal "${lines[15]}"  "Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)"
}

@test "TOC for markdown from stdin" {
    cat README.md | {
        run $BATS_TEST_DIRNAME/../gh-md-toc -
        assert_success
        assert_equal "${lines[0]}"  "  * [gh-md-toc](#gh-md-toc)"
        assert_equal "${lines[1]}"  "  * [Table of contents](#table-of-contents)"
        assert_equal "${lines[2]}"  "  * [Installation](#installation)"
        assert_equal "${lines[3]}"  "  * [Usage](#usage)"
        assert_equal "${lines[4]}"  "    * [STDIN](#stdin)"
        assert_equal "${lines[5]}"  "    * [Local files](#local-files)"
        assert_equal "${lines[6]}"  "    * [Remote files](#remote-files)"
        assert_equal "${lines[7]}"  "    * [Multiple files](#multiple-files)"
        assert_equal "${lines[8]}"  "    * [Combo](#combo)"
        assert_equal "${lines[9]}"  "  * [Tests](#tests)"
        assert_equal "${lines[10]}" "  * [Dependency](#dependency)"
    }
}

@test "--help" {
    run $BATS_TEST_DIRNAME/../gh-md-toc --help
    assert_success
    assert_equal "${lines[1]}" "Usage:"
    assert_equal "${lines[2]}" "  gh-md-toc src [src]     Create TOC for a README file (url or local path)"
    assert_equal "${lines[3]}" "  gh-md-toc -             Create TOC for markdown from STDIN"
    assert_equal "${lines[4]}" "  gh-md-toc --help        Show help"
    assert_equal "${lines[5]}" "  gh-md-toc --version     Show version"
}

@test "no arguments" {
    run $BATS_TEST_DIRNAME/../gh-md-toc
    assert_success
    assert_equal "${lines[1]}" "Usage:"
    assert_equal "${lines[2]}" "  gh-md-toc src [src]     Create TOC for a README file (url or local path)"
    assert_equal "${lines[3]}" "  gh-md-toc -             Create TOC for markdown from STDIN"
    assert_equal "${lines[4]}" "  gh-md-toc --help        Show help"
    assert_equal "${lines[5]}" "  gh-md-toc --version     Show version"
}

@test "--version" {
    run $BATS_TEST_DIRNAME/../gh-md-toc --version
    assert_success
    assert_equal "${lines[0]}" "0.4.6"
}

@test "TOC for non-english chars, #6, #10" {
    run $BATS_TEST_DIRNAME/../gh-md-toc \
        https://github.com/ekalinin/envirius/blob/f939d3b6882bfb6ecb28ef7b6e62862f934ba945/README.ru.md 
    assert_success

    assert_equal "${lines[2]}"   "  * [envirius](#envirius)"
    assert_equal "${lines[3]}"   "    * [Идея](#Идея)"
    assert_equal "${lines[4]}"   "    * [Особенности](#Особенности)"
    assert_equal "${lines[5]}"   "  * [Установка](#Установка)"


    run $BATS_TEST_DIRNAME/../gh-md-toc \
        https://github.com/jlevy/the-art-of-command-line/blob/217da3b4fa751014ecc122fd9fede2328a7eeb3e/README-zh.md
    assert_success

    assert_equal "${lines[2]}"   "  * [命令行的艺术](#命令行的艺术)"
    assert_equal "${lines[3]}"   "    * [必读](#必读)"
    assert_equal "${lines[4]}"   "    * [基础](#基础)"
    assert_equal "${lines[5]}"   "    * [日常使用](#日常使用)"


    run $BATS_TEST_DIRNAME/../gh-md-toc \
        https://github.com/jlevy/the-art-of-command-line/blob/217da3b4fa751014ecc122fd9fede2328a7eeb3e/README-pt.md
    assert_success

    assert_equal "${lines[2]}"   "  * [A arte da linha de comando](#a-arte-da-linha-de-comando)"
    assert_equal "${lines[3]}"   "    * [Meta](#meta)"
    assert_equal "${lines[4]}"   "    * [Básico](#básico)"
    assert_equal "${lines[5]}"   "    * [Uso diário](#uso-diário)"
}

@test "TOC for text with backquote, #13" {
    run $BATS_TEST_DIRNAME/../gh-md-toc tests/test_backquote.md
    assert_success

    assert_equal "${lines[2]}"   "  * [The command foo1 ](#the-command-foo1)"
    assert_equal "${lines[3]}"   "    * [The command foo2 is better](#the-command-foo2-is-better)"
    assert_equal "${lines[4]}"   "  * [The command bar1 ](#the-command-bar1)"
    assert_equal "${lines[5]}"   "    * [The command bar2 is better](#the-command-bar2-is-better)"
    assert_equal "${lines[6]}"   "      * [The command bar3 is the best](#the-command-bar3-is-the-best)"
}
