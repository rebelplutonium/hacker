#!/bin/sh

for VOLUME in $(sudo docker volume ls --filter label=expiry --filter dangling=true --quiet)
do
    if [ $(sudo docker volume inspect ${VOLUME} --format "{{ .Labels.expiry }}") -lt $(date +%s) ]
    then
        sudo docker volume rm ${VOLUME}
    fi
done