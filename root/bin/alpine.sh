#!/bin/sh

CIDFILE=$(mktemp /srv/ids/containers/XXXXXXXX) &&
    docker \
        container \
        create \
        --cidfile ${CIDFILE} \
        --interactive \
        --tty \
        --rm \
        --env DISPLAY \
        --mount type=bind,source=/tmp/.X11-unix/X0,destination=/tmp/.X11-unix/X0,readonly=true \
        --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock,readonly=true \
        --label expiry=$(($(date +%s)+60*60*24*7)) \
        alpine:3.4 \
        sh