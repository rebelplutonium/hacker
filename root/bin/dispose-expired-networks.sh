#!/bin/sh

sudo /usr/bin/docker network ls --quiet --filter label=expiry | while read NETWORK
do
    if [ -z $(sudo /usr/bin/docker container ls --quiet --filter --all network=${NETWORK}) ]
    then
        if [ -z "$(sudo /usr/bin/docker network inspect --format \"{{.Labels.expiry}}\" ${NETWORK})" ] || [ $(sudo /usr/bin/docker network inspect --format "{{.Labels.expiry}}" ${NETWORK}) -lt $(date +%s) ]
        then
            sudo /usr/bin/docker network rm ${NETWORK}
        fi
    fi
done