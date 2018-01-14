#!/bin/sh

sudo \
    --preserve-env \
    /usr/bin/docker \
    container \
    run \
    --interactive \
    --tty \
    --rm \
    --label expiry=$(($(date +%s)+60*60*24*7)) \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --volume ${EXTERNAL_IDS_VOLUME}:/srv/ids \
    docker:17.12.0 \
    "${@}"
