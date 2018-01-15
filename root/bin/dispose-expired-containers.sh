#!/bin/sh

(
    sudo /usr/bin/docker container ls --quiet --all --filter label=expired --filter status=created &&
        sudo /usr/bin/docker container ls --quiet --all --filter label=expired --filter status=exited &&
        sudo /usr/bin/docker container ls --quiet --all --filter label=expired --filter status=dead
) | while read CONTAINER
do
    if [ -z "$(sudo /usr/bin/docker container inspect --format \"{{.Config.Labels.expiry}}\" ${CONTAINER})" ] ||  [ $(sudo /usr/bin/docker container inspect --format "{{.Config.Labels.expiry}}" ${CONTAINER}) -lt $(date +%s) ]
    then
        sudo /usr/bin/docker container rm --volumes ${CONTAINER}
    fi
done