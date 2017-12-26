#!/bin/sh

for CONTAINER in $(sudo docker container ls --all --filter label=expiry --quiet)
do
    if [ $(sudo docker container inspect ${CONTAINER} --format "{{ .Config.Labels.expiry }}") -lt $(date +%s) ]
    then
        sudo docker container rm --volumes ${CONTAINER}
    fi
done