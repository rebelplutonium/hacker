#!/bin/sh

for VOLUME in $(docker volume ls --filter dangling=true --quiet)
do
    [ -z "$(docker container run --interactive --rm --label expiry=$(($(date +%s)+60*60*24*7)) --volume ${VOLUME}:/volume:ro alpine:3.4 find /volume -mindepth 1)" ] &&
        echo ${VOLUME}
done