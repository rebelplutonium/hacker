#!/bin/sh

sudo /usr/bin/docker volume ls --quiet --filter dangling=true --filter label=expiry | while read VOLUME
do
    if [ -z "$(sudo /usr/bin/docker volume inspect --format \"{{.Labels.expiry}}\" ${VOLUME})" ] || [ $(sudo /usr/bin/docker volume inspect --format "{{.Labels.expiry}}" ${VOLUME}) -lt $(date +%s) ]
    then
        sudo /usr/bin/docker volume rm ${VOLUME}
    fi
done