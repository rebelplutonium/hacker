#!/bin/sh

sudo /usr/bin/docker image ls --quiet --filter dangling=true --filter label=expiry | while read IMAGE
do
    if [ -z "$(sudo /usr/bin/docker image inspect --format \"{{.Config.Labels.expiry}}\" ${IMAGE})" ] || [ $(sudo /usr/bin/docker image inspect --format "{{.Configs.Labels.expiry}}" ${IMAGE}) -lt $(date +%s) ]
    then
        sudo /usr/bin/docker image rm ${IMAGE}
    fi
done