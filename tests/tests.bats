#!/usr/bin/env bats

load test_helper


@test "TOC for local README.md" {
    run $BATS_TEST_DIRNAME/../gh-md-toc README.md
    assert_success

    assert_equal "${lines[0]}"  "Table of Contents"
    assert_equal "${lines[1]}"  "================="
    assert_equal "${lines[2]}"  "* [gh-md-toc](#gh-md-toc)"
    assert_equal "${lines[3]}"  "* [Table of contents](#table-of-contents)"
    assert_equal "${lines[4]}"  "* [Installation](#installation)"
    assert_equal "${lines[5]}"  "* [Usage](#usage)"
    assert_equal "${lines[6]}"  "   * [STDIN](#stdin)"
    assert_equal "${lines[7]}"  "   * [Local files](#local-files)"
    assert_equal "${lines[8]}"  "   * [Remote files](#remote-files)"
    assert_equal "${lines[9]}"  "   * [Multiple files](#multiple-files)"
    assert_equal "${lines[10]}" "   * [Combo](#combo)"
    assert_equal "${lines[11]}" "   * [Auto insert and update TOC](#auto-insert-and-update-toc)"
    assert_equal "${lines[12]}" "   * [GitHub token](#github-token)"
    assert_equal "${lines[13]}" "   * [TOC generation with Github Actions](#toc-generation-with-github-actions)"
    assert_equal "${lines[14]}" "* [Tests](#tests)"
    assert_equal "${lines[15]}" "* [Dependency](#dependency)"
    assert_equal "${lines[16]}" "* [Docker](#docker)"
    assert_equal "${lines[17]}" "   * [Local](#local)"
    assert_equal "${lines[18]}" "   * [Public](#public)"
    assert_equal "${lines[19]}" "<!-- Created by https://github.com/ekalinin/github-markdown-toc -->"

}

@test "TOC for local README.md with skip headers" {
    run $BATS_TEST_DIRNAME/../gh-md-toc --skip-header README.md
    assert_success

    assert_equal "${lines[0]}"  "Table of Contents"
    assert_equal "${lines[1]}"  "================="
    assert_equal "${lines[2]}"  "* [Installation](#installation)"
    assert_equal "${lines[3]}"  "* [Usage](#usage)"
    assert_equal "${lines[4]}"  "   * [STDIN](#stdin)"
    assert_equal "${lines[5]}"  "   * [Local files](#local-files)"
    assert_equal "${lines[6]}"  "   * [Remote files](#remote-files)"
    assert_equal "${lines[7]}"  "   * [Multiple files](#multiple-files)"
    assert_equal "${lines[8]}" "   * [Combo](#combo)"
    assert_equal "${lines[9]}" "   * [Auto insert and update TOC](#auto-insert-and-update-toc)"
    assert_equal "${lines[10]}" "   * [GitHub token](#github-token)"
    assert_equal "${lines[11]}" "   * [TOC generation with Github Actions](#toc-generation-with-github-actions)"
    assert_equal "${lines[12]}" "* [Tests](#tests)"
    assert_equal "${lines[13]}" "* [Dependency](#dependency)"
    assert_equal "${lines[14]}" "* [Docker](#docker)"
    assert_equal "${lines[15]}" "   * [Local](#local)"
    assert_equal "${lines[16]}" "   * [Public](#public)"
    assert_equal "${lines[17]}" "<!-- Created by https://github.com/ekalinin/github-markdown-toc -->"

}
# @test "TOC for remote README.md" {
#     run $BATS_TEST_DIRNAME/../gh-md-toc https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md
#     assert_success
#
#     assert_equal "${lines[0]}"  "Table of Contents"
#     assert_equal "${lines[1]}"  "================="
#     assert_equal "${lines[2]}"  "* [sitemap.js](#sitemapjs)"
#     assert_equal "${lines[3]}"  "   * [Installation](#installation)"
#     assert_equal "${lines[4]}"  "   * [Usage](#usage)"
#     assert_equal "${lines[5]}"  "   * [License](#license)"
#     assert_equal "${lines[6]}"  "<!-- Created by https://github.com/ekalinin/github-markdown-toc -->"
# }

# @test "TOC for mixed README.md (remote/local)" {
#     run $BATS_TEST_DIRNAME/../gh-md-toc \
#         README.md \
#         https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md
#     assert_success
#
#     assert_equal "${lines[0]}"   "* [gh-md-toc](README.md#gh-md-toc)"
#     assert_equal "${lines[1]}"   "* [Table of contents](README.md#table-of-contents)"
#     assert_equal "${lines[2]}"   "* [Installation](README.md#installation)"
#     assert_equal "${lines[3]}"   "* [Usage](README.md#usage)"
#     assert_equal "${lines[4]}"   "   * [STDIN](README.md#stdin)"
#     assert_equal "${lines[5]}"   "   * [Local files](README.md#local-files)"
#     assert_equal "${lines[6]}"   "   * [Remote files](README.md#remote-files)"
#     assert_equal "${lines[7]}"   "   * [Multiple files](README.md#multiple-files)"
#     assert_equal "${lines[8]}"   "   * [Combo](README.md#combo)"
#     assert_equal "${lines[9]}"   "   * [Auto insert and update TOC](README.md#auto-insert-and-update-toc)"
#     assert_equal "${lines[10]}"  "   * [GitHub token](README.md#github-token)"
#     assert_equal "${lines[11]}"  "   * [TOC generation with Github Actions](README.md#toc-generation-with-github-actions)"
#     assert_equal "${lines[12]}"  "* [Tests](README.md#tests)"
#     assert_equal "${lines[13]}"  "* [Dependency](README.md#dependency)"
#     assert_equal "${lines[14]}"  "* [Docker](README.md#docker)"
#     assert_equal "${lines[15]}" "   * [Local](README.md#local)"
#     assert_equal "${lines[16]}" "   * [Public](README.md#public)"
#     assert_equal "${lines[17]}"  "* [sitemap.js](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#sitemapjs)"
#     assert_equal "${lines[18]}"  "   * [Installation](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#installation)"
#     assert_equal "${lines[19]}"  "   * [Usage](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#usage)"
#     assert_equal "${lines[20]}"  "   * [License](https://github.com/ekalinin/sitemap.js/blob/6bc3eb12c898c1037a35a11b2eb24ababdeb3580/README.md#license)"
#     assert_equal "${lines[21]}"  "<!-- Created by https://github.com/ekalinin/github-markdown-toc -->"
# }

@test "TOC for markdown from stdin" {
    cat README.md | {
        run $BATS_TEST_DIRNAME/../gh-md-toc -
        assert_success
        assert_equal "${lines[0]}"  "* [gh-md-toc](#gh-md-toc)"
        assert_equal "${lines[1]}"  "* [Table of contents](#table-of-contents)"
        assert_equal "${lines[2]}"  "* [Installation](#installation)"
        assert_equal "${lines[3]}"  "* [Usage](#usage)"
        assert_equal "${lines[4]}"  "   * [STDIN](#stdin)"
        assert_equal "${lines[5]}"  "   * [Local files](#local-files)"
        assert_equal "${lines[6]}"  "   * [Remote files](#remote-files)"
        assert_equal "${lines[7]}"  "   * [Multiple files](#multiple-files)"
        assert_equal "${lines[8]}"  "   * [Combo](#combo)"
        assert_equal "${lines[9]}"  "   * [Auto insert and update TOC](#auto-insert-and-update-toc)"
        assert_equal "${lines[10]}" "   * [GitHub token](#github-token)"
        assert_equal "${lines[11]}" "   * [TOC generation with Github Actions](#toc-generation-with-github-actions)"
        assert_equal "${lines[12]}" "* [Tests](#tests)"
        assert_equal "${lines[13]}" "* [Dependency](#dependency)"
    }
}

test_help() {
    assert_equal "${lines[1]}"  "Usage:"
    assert_equal "${lines[2]}"  "  gh-md-toc [options] src [src]   Create TOC for a README file (url or local path)"
    assert_equal "${lines[3]}"  "  gh-md-toc -                     Create TOC for markdown from STDIN"
    assert_equal "${lines[4]}"  "  gh-md-toc --help                Show help"
    assert_equal "${lines[5]}"  "  gh-md-toc --version             Show version"
    assert_equal "${lines[6]}"  "Options:"
    assert_equal "${lines[7]}"  "  --indent <NUM>      Set indent size. Default: 3."
    assert_equal "${lines[8]}"  "  --insert            Insert new TOC into original file. For local files only. Default: false."
    assert_equal "${lines[10]}" "  --no-backup         Remove backup file. Set --insert as well. Default: false."
    assert_equal "${lines[11]}" "  --hide-footer       Do not write date & author of the last TOC update. Set --insert as well. Default: false."
    assert_equal "${lines[12]}" "  --skip-header       Hide entry of the topmost headlines. Default: false."
    assert_equal "${#lines[@]}"  "14"
}

@test "--help" {
    run $BATS_TEST_DIRNAME/../gh-md-toc --help
    assert_success
    test_help
}

@test "no arguments" {
    run $BATS_TEST_DIRNAME/../gh-md-toc
    assert_success
    test_help
}

@test "--version" {
    run $BATS_TEST_DIRNAME/../gh-md-toc --version
    assert_success
    assert_equal "${lines[0]}" "0.10.0"
    assert_equal "${lines[1]}" "os:     `uname -s`"
    assert_equal "${lines[2]}" "arch:   `uname -m`"
}

@test "TOC for non-english chars, #6, #10" {
    run $BATS_TEST_DIRNAME/../gh-md-toc tests/test\ directory/test_nonenglishchars.md
    assert_success

    assert_equal "${lines[2]}"   "* [命令行的艺术](#命令行的艺术)"
    assert_equal "${lines[3]}"   "   * [必读](#必读)"
    assert_equal "${lines[4]}"   "   * [基础](#基础)"
    assert_equal "${lines[5]}"   "   * [日常使用](#日常使用)"
}

# @test "TOC for remote non-english chars (remote load), #6, #10" {
#     run $BATS_TEST_DIRNAME/../gh-md-toc \
#         https://github.com/ekalinin/envirius/blob/f939d3b6882bfb6ecb28ef7b6e62862f934ba945/README.ru.md
#     assert_success
#
#     assert_equal "${lines[2]}"   "* [envirius](#envirius)"
#     assert_equal "${lines[3]}"   "   * [Идея](#идея)"
#     assert_equal "${lines[4]}"   "   * [Особенности](#особенности)"
#     assert_equal "${lines[5]}"   "* [Установка](#установка)"
#
#
#     run $BATS_TEST_DIRNAME/../gh-md-toc \
#         https://github.com/jlevy/the-art-of-command-line/blob/217da3b4fa751014ecc122fd9fede2328a7eeb3e/README-zh.md
#     assert_success
#
#     assert_equal "${lines[2]}"   "* [命令行的艺术](#命令行的艺术)"
#     assert_equal "${lines[3]}"   "   * [必读](#必读)"
#     assert_equal "${lines[4]}"   "   * [基础](#基础)"
#     assert_equal "${lines[5]}"   "   * [日常使用](#日常使用)"
#
#
#     run $BATS_TEST_DIRNAME/../gh-md-toc \
#         https://github.com/jlevy/the-art-of-command-line/blob/217da3b4fa751014ecc122fd9fede2328a7eeb3e/README-pt.md
#     assert_success
#
#     assert_equal "${lines[2]}"   "* [A arte da linha de comando](#a-arte-da-linha-de-comando)"
#     assert_equal "${lines[3]}"   "   * [Meta](#meta)"
#     assert_equal "${lines[4]}"   "   * [Básico](#básico)"
#     assert_equal "${lines[5]}"   "   * [Uso diário](#uso-diário)"
# }

@test "TOC for text with backquote, #13" {
    run $BATS_TEST_DIRNAME/../gh-md-toc tests/test\ directory/test_backquote.md
    assert_success

    assert_equal "${lines[2]}"   "* [The command foo1](#the-command-foo1)"
    assert_equal "${lines[3]}"   "   * [The command foo2 is better](#the-command-foo2-is-better)"
    assert_equal "${lines[4]}"   "* [The command bar1](#the-command-bar1)"
    assert_equal "${lines[5]}"   "   * [The command bar2 is better](#the-command-bar2-is-better)"
    assert_equal "${lines[6]}"   "      * [The command bar3 is the best](#the-command-bar3-is-the-best)"
}

@test "TOC for text with plus signs, #100" {
    run $BATS_TEST_DIRNAME/../gh-md-toc tests/test\ directory/test_plussign.md
    assert_success

    assert_equal "${lines[2]}" "* [C vs C++](#c-vs-c)"
}

@test "Toc for file path with space, #136" {
    run $BATS_TEST_DIRNAME/../gh-md-toc --no-backup --hide-footer tests/test\ directory/test_filepathwithspace.md
    assert_success

    assert_equal "${lines[2]}"   "* [Title](#title)"
    assert_equal "${lines[3]}"   "   * [This is test for file path with space](#this-is-test-for-file-path-with-space)"
}

@test "Toc for setext heading with formatting, #145" {
    run $BATS_TEST_DIRNAME/../gh-md-toc --no-backup --hide-footer tests/test\ directory/test_setextwithformatting.md
    assert_success

    assert_equal "${lines[2]}"   "* [Title one](#title-one)"
    assert_equal "${lines[3]}"   "   * [This is test for setext-style without formatting](#this-is-test-for-setext-style-without-formatting)"
    assert_equal "${lines[4]}"   "* [<em>Title two</em>](#title-two)"
    assert_equal "${lines[5]}"   "   * [This is test for setext-style with formatting](#this-is-test-for-setext-style-with-formatting)"
    assert_equal "${lines[6]}"   "* [Title three](#title-three)"
    assert_equal "${lines[7]}"   "   * [This is a regression test for atx-style](#this-is-a-regression-test-for-atx-style)"
    assert_equal "${lines[8]}"   "* [Title four is a particularly long title because of wrapping](#title-four-is-a-particularly-long-title-because-of-wrapping)"
    assert_equal "${lines[9]}"   "   * [This is a test for long titles](#this-is-a-test-for-long-titles)"
}
