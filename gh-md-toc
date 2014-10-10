#!/usr/bin/env bash

#
# Steps:
#
#  1. Download coresponding html file for some README.md:
#       curl -s $1
#
#  2. Discard rows where no substring 'user-content-' (github's markup):
#       awk '/user-content-/ { ...
#
#  3. Get header level and insert corresponding number of spaces before '*':
#       sprintf("%*s", substr($NF, length($NF)-1, 1)*2, " ")
#
#  4. Find head's text and insert it inside "* [ ... ]":
#       substr($0, match($0, /a>.*<\/h/)+2, RLENGTH-5)
#
#  5. Find anchor and insert it inside "(...)":
#       substr($4, 7)
#

gh_toc_version="0.2.1"

#
# Download rendered into html README.md by it's url.
#
#
gh_toc_load() {
    local gh_url=$1
    local gh_user_agent=$2

    if type curl &>/dev/null; then
        curl --user-agent "$gh_user_agent" -s "$gh_url"
    elif type wget &>/dev/null; then
        wget --user-agent="$gh_user_agent" -qO- "$gh_url"
    else
        echo "Please, install 'curl' or 'wget' and try again."
        exit 1
    fi
}

#
# TOC generator
#
gh_toc(){
    local gh_url=$1
    local gh_user_agent=${2:-"gh-md-toc"}
    local gh_count=$3

    if [ "$gh_url" = "" ]; then
        echo "Please, enter URL for a README.md"
        exit 1
    fi

    if [ "$gh_count" = "1" ]; then

        echo "Table of Contents"
        echo "================="
        echo ""

        gh_toc_load "$gh_url" "$gh_user_agent" | gh_toc_grab ""
    else
        gh_toc_load "$gh_url" "$gh_user_agent" | gh_toc_grab "$gh_url"
    fi
}

gh_toc_grab() {
    awk -v "gh_url=$1" '/user-content-/ {
    print sprintf("%*s", substr($NF, length($NF)-1, 1)*2, " ") "* [" substr($0, match($0, /a>.*<\/h/)+2, RLENGTH-5)"](" gh_url substr($4, 7, length($4)-7) ")"}'
}

#
# Returns filename only from full path or url
#
gh_toc_get_filename() {
    echo "${1##*/}"
}

#
# Options hendlers
#
gh_toc_app() {
    local app_name=${0/\.\//}

    if [ "$1" = '--help' ]; then
        echo "GitHub TOC generator ($app_name): $gh_toc_version"
        echo ""
        echo "Usage:"
        echo "  $app_name <url>         Create TOC for passed url of a README file"
        echo "  $app_name --help        Show help"
        echo "  $app_name --version     Show help"
        return
    fi

    if [ "$1" = '--version' ]; then
        echo "$gh_toc_version"
        return
    fi

    for md in "$@"
    do
        echo ""
        gh_toc "$md" "$app_name" "$#"
    done

    echo ""
    echo "Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)"
}

#
# Entry point
#
gh_toc_app "$@"
