#!/bin/sh

sudo \
    /usr/bin/docker \
    --interactive \
    --tty \
    --rm \
    --label expiry=$(($(date +%s)+60*60*24*7)) \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --volume ${EXTERNAL_IDS_VOLUME}:/srv/ids \
    "${@}"