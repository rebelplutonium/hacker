#!/bin/sh

docker container run --interactive --tty --rm --volume /:/srv:ro --workdir /srv --label expiry=$(($(date +%s)+60*60*24*7)) fedora:27 bash