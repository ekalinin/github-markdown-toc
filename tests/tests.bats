#!/usr/bin/env bats

load test_helper


@test "TOC for local README.md" {
    run $BATS_TEST_DIRNAME/../gh-md-toc README.md
    assert_success

    assert_equal "${lines[0]}"  "Table of Contents"
    assert_equal "${lines[1]}"  "================="
    assert_equal "${lines[2]}"  "   * [gh-md-toc](#gh-md-toc)"
    assert_equal "${lines[3]}"  "   * [Table of contents](#table-of-contents)"
    assert_equal "${lines[4]}"  "   * [Installation](#installation)"
    assert_equal "${lines[5]}"  "   * [Usage](#usage)"
    assert_equal "${lines[6]}"  "      * [STDIN](#stdin)"
    assert_equal "${lines[7]}"  "      * [Local files](#local-files)"
    assert_equal "${lines[8]}"  "      * [Remote files](#remote-files)"
    assert_equal "${lines[9]}"  "      * [Multiple files](#multiple-files)"
    assert_equal "${lines[10]}" "      * [Combo](#combo)"
    assert_equal "${lines[11]}" "      * [Auto insert and update TOC](#auto-insert-and-update-toc)"
    assert_equal "${lines[12]}" "      * [GitHub token](#github-token)"
    assert_equal "${lines[13]}" "   * [Tests](#tests)"
    assert_equal "${lines[14]}" "   * [Dependency](#dependency)"
    assert_equal "${lines[15]}" "   * [Docker](#docker)"
    assert_equal "${lines[16]}" "      * [Local](#local)"
    assert_equal "${lines[17]}" "      * [Public](#public)"
    assert_equal "${lines[18]}" "Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)"

}

@test "TOC for remote README.md" {
    run $BATS_TEST_DIRNAME/../gh-md-toc https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md
    assert_success

    assert_equal "${lines[0]}"  "Table of Contents"
    assert_equal "${lines[1]}"  "================="
    assert_equal "${lines[2]}"  "   * [sitemap.js](#sitemapjs)"
    assert_equal "${lines[3]}"  "      * [Installation](#installation)"
    assert_equal "${lines[4]}"  "      * [Usage](#usage)"
    assert_equal "${lines[5]}"  "      * [License](#license)"
    assert_equal "${lines[6]}"  "Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)"
}

@test "TOC for mixed README.md (remote/local)" {
    run $BATS_TEST_DIRNAME/../gh-md-toc \
        README.md \
        https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md
    assert_success

    assert_equal "${lines[0]}"   "   * [gh-md-toc](README.md#gh-md-toc)"
    assert_equal "${lines[1]}"   "   * [Table of contents](README.md#table-of-contents)"
    assert_equal "${lines[2]}"   "   * [Installation](README.md#installation)"
    assert_equal "${lines[3]}"   "   * [Usage](README.md#usage)"
    assert_equal "${lines[4]}"   "      * [STDIN](README.md#stdin)"
    assert_equal "${lines[5]}"   "      * [Local files](README.md#local-files)"
    assert_equal "${lines[6]}"   "      * [Remote files](README.md#remote-files)"
    assert_equal "${lines[7]}"   "      * [Multiple files](README.md#multiple-files)"
    assert_equal "${lines[8]}"   "      * [Combo](README.md#combo)"
    assert_equal "${lines[9]}"   "      * [Auto insert and update TOC](README.md#auto-insert-and-update-toc)"
    assert_equal "${lines[10]}"  "      * [GitHub token](README.md#github-token)"
    assert_equal "${lines[11]}"  "   * [Tests](README.md#tests)"
    assert_equal "${lines[12]}"  "   * [Dependency](README.md#dependency)"
    assert_equal "${lines[13]}"  "   * [Docker](README.md#docker)"
    assert_equal "${lines[14]}" "      * [Local](README.md#local)"
    assert_equal "${lines[15]}" "      * [Public](README.md#public)"
    assert_equal "${lines[16]}"  "   * [sitemap.js](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#sitemapjs)"
    assert_equal "${lines[17]}"  "      * [Installation](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#installation)"
    assert_equal "${lines[18]}"  "      * [Usage](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#usage)"
    assert_equal "${lines[19]}"  "      * [License](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#license)"
    assert_equal "${lines[20]}"  "Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)"
}

@test "TOC for markdown from stdin" {
    cat README.md | {
        run $BATS_TEST_DIRNAME/../gh-md-toc -
        assert_success
        assert_equal "${lines[0]}"  "   * [gh-md-toc](#gh-md-toc)"
        assert_equal "${lines[1]}"  "   * [Table of contents](#table-of-contents)"
        assert_equal "${lines[2]}"  "   * [Installation](#installation)"
        assert_equal "${lines[3]}"  "   * [Usage](#usage)"
        assert_equal "${lines[4]}"  "      * [STDIN](#stdin)"
        assert_equal "${lines[5]}"  "      * [Local files](#local-files)"
        assert_equal "${lines[6]}"  "      * [Remote files](#remote-files)"
        assert_equal "${lines[7]}"  "      * [Multiple files](#multiple-files)"
        assert_equal "${lines[8]}"  "      * [Combo](#combo)"
        assert_equal "${lines[9]}"  "      * [Auto insert and update TOC](#auto-insert-and-update-toc)"
        assert_equal "${lines[10]}" "      * [GitHub token](#github-token)"
        assert_equal "${lines[11]}" "   * [Tests](#tests)"
        assert_equal "${lines[12]}" "   * [Dependency](#dependency)"
    }
}

@test "--help" {
    run $BATS_TEST_DIRNAME/../gh-md-toc --help
    assert_success
    assert_equal "${lines[1]}" "Usage:"
    assert_equal "${lines[2]}" "  gh-md-toc [--insert] [--hide-footer] src [src]  Create TOC for a README file (url or local path)"
    assert_equal "${lines[3]}" "  gh-md-toc [--no-backup] [--hide-footer] src [src]  Create TOC without backup, requires <!--ts--> / <!--te--> placeholders"
    assert_equal "${lines[4]}" "  gh-md-toc --all                 Find all Markdown files for non-hidden folders"
    assert_equal "${lines[5]}" "  gh-md-toc --auto                Ignore ts/te tags, Automatically at the end/head of the file"
    assert_equal "${lines[6]}" "  gh-md-toc --head                The TOC is generated in the header of the file, requires --auto"
    assert_equal "${lines[7]}" "  gh-md-toc -                     Create TOC for markdown from STDIN"
    assert_equal "${lines[8]}" "  gh-md-toc --help                Show help"
    assert_equal "${lines[9]}" "  gh-md-toc --version             Show version"
}

@test "no arguments" {
    run $BATS_TEST_DIRNAME/../gh-md-toc
    assert_success
    assert_equal "${lines[1]}" "Usage:"
    assert_equal "${lines[2]}" "  gh-md-toc [--insert] [--hide-footer] src [src]  Create TOC for a README file (url or local path)"
    assert_equal "${lines[3]}" "  gh-md-toc [--no-backup] [--hide-footer] src [src]  Create TOC without backup, requires <!--ts--> / <!--te--> placeholders"
    assert_equal "${lines[4]}" "  gh-md-toc --all                 Find all Markdown files for non-hidden folders"
    assert_equal "${lines[5]}" "  gh-md-toc --auto                Ignore ts/te tags, Automatically at the end/head of the file"
    assert_equal "${lines[6]}" "  gh-md-toc --head                The TOC is generated in the header of the file, requires --auto"
    assert_equal "${lines[7]}" "  gh-md-toc -                     Create TOC for markdown from STDIN"
    assert_equal "${lines[8]}" "  gh-md-toc --help                Show help"
    assert_equal "${lines[9]}" "  gh-md-toc --version             Show version"
}

@test "--version" {
    run $BATS_TEST_DIRNAME/../gh-md-toc --version
    assert_success
    assert_equal "${lines[0]}" "0.7.0"
}

@test "TOC for non-english chars, #6, #10" {
    run $BATS_TEST_DIRNAME/../gh-md-toc \
        https://github.com/ekalinin/envirius/blob/f939d3b6882bfb6ecb28ef7b6e62862f934ba945/README.ru.md
    assert_success

    assert_equal "${lines[2]}"   "   * [envirius](#envirius)"
    assert_equal "${lines[3]}"   "      * [Идея](#идея)"
    assert_equal "${lines[4]}"   "      * [Особенности](#особенности)"
    assert_equal "${lines[5]}"   "   * [Установка](#установка)"


    run $BATS_TEST_DIRNAME/../gh-md-toc \
        https://github.com/jlevy/the-art-of-command-line/blob/217da3b4fa751014ecc122fd9fede2328a7eeb3e/README-zh.md
    assert_success

    assert_equal "${lines[2]}"   "   * [命令行的艺术](#命令行的艺术)"
    assert_equal "${lines[3]}"   "      * [必读](#必读)"
    assert_equal "${lines[4]}"   "      * [基础](#基础)"
    assert_equal "${lines[5]}"   "      * [日常使用](#日常使用)"


    run $BATS_TEST_DIRNAME/../gh-md-toc \
        https://github.com/jlevy/the-art-of-command-line/blob/217da3b4fa751014ecc122fd9fede2328a7eeb3e/README-pt.md
    assert_success

    assert_equal "${lines[2]}"   "   * [A arte da linha de comando](#a-arte-da-linha-de-comando)"
    assert_equal "${lines[3]}"   "      * [Meta](#meta)"
    assert_equal "${lines[4]}"   "      * [Básico](#básico)"
    assert_equal "${lines[5]}"   "      * [Uso diário](#uso-diário)"
}

@test "TOC for text with backquote, #13" {
    run $BATS_TEST_DIRNAME/../gh-md-toc tests/test_backquote.md
    assert_success

    assert_equal "${lines[2]}"   "   * [The command foo1](#the-command-foo1)"
    assert_equal "${lines[3]}"   "      * [The command foo2 is better](#the-command-foo2-is-better)"
    assert_equal "${lines[4]}"   "   * [The command bar1](#the-command-bar1)"
    assert_equal "${lines[5]}"   "      * [The command bar2 is better](#the-command-bar2-is-better)"
    assert_equal "${lines[6]}"   "         * [The command bar3 is the best](#the-command-bar3-is-the-best)"
}

@test "TOC for text with plus signs, #100" {
    run $BATS_TEST_DIRNAME/../gh-md-toc tests/test_plussign.md
    assert_success

    assert_equal "${lines[2]}"   "   * [C vs C++](#c-vs-c)"
}

@test "TOC for local all" {
	run $BATS_TEST_DIRNAME/../gh-md-toc --all
	assert_success

	assert_equal "${lines[0]}" "   * [The command foo1](test_backquote.md#the-command-foo1)"
	assert_equal "${lines[1]}" "      * [The command foo2 is better](test_backquote.md#the-command-foo2-is-better)"
	assert_equal "${lines[2]}" "   * [The command bar1](test_backquote.md#the-command-bar1)"
	assert_equal "${lines[3]}" "      * [The command bar2 is better](test_backquote.md#the-command-bar2-is-better)"
	assert_equal "${lines[4]}" "         * [The command bar3 is the best](test_backquote.md#the-command-bar3-is-the-best)"

	assert_equal "${lines[5]}" "   * [C vs C++](test_plussign.md#c-vs-c)"

	assert_equal "${lines[6]}" "   * [gh-md-toc](README.md#gh-md-toc)"
	assert_equal "${lines[7]}" "   * [Table of contents](README.md#table-of-contents)"
	assert_equal "${lines[8]}" "   * [Installation](README.md#installation)"
	assert_equal "${lines[9]}" "   * [Usage](README.md#usage)"
	assert_equal "${lines[10]}" "      * [STDIN](README.md#stdin)"
	assert_equal "${lines[11]}" "      * [Local files](README.md#local-files)"
	assert_equal "${lines[12]}" "      * [Remote files](README.md#remote-files)"
	assert_equal "${lines[13]}" "      * [Multiple files](README.md#multiple-files)"
	assert_equal "${lines[14]}" "      * [Combo](README.md#combo)"
	assert_equal "${lines[15]}" "      * [Auto insert and update TOC](README.md#auto-insert-and-update-toc)"
	assert_equal "${lines[16]}" "      * [GitHub token](README.md#github-token)"
	assert_equal "${lines[17]}" "      * [TOC generation with Github Actions](README.md#toc-generation-with-github-actions)"
	assert_equal "${lines[18]}" "   * [Tests](README.md#tests)"
	assert_equal "${lines[19]}" "   * [Dependency](README.md#dependency)"
	assert_equal "${lines[20]}" "   * [Docker](README.md#docker)"
	assert_equal "${lines[21]}" "      * [Local](README.md#local)"
	assert_equal "${lines[22]}" "      * [Public](README.md#public)"
}
