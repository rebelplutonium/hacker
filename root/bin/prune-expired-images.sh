#!/bin/sh

for IMAGE in $(sudo docker image ls --filter dangling=true --filter label=expiry --quiet)
do
    if [ $(sudo docker image inspect ${IMAGE} --format "{{ .Config.Labels.expiry }}") -lt $(date +%s) ]
    then
        sudo docker image rm ${IMAGE}
    fi
done