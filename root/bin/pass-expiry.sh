#!/bin/sh

CUTOFF=$(($(date +%s)-60*60*24*7)) &&
    pass git ls-tree -r --name-only HEAD | grep ".gpg\$" | while read FILE
    do
        [ $(pass git log -1 --format=%at -- ${FILE}) -lt ${CUTOFF} ] &&
            pass git log -1 --format="$(pass show ${FILE%.*} | wc --bytes) %at ${FILE%.*}" -- ${FILE}
    done | sort -nk 2 | sort -nk 1