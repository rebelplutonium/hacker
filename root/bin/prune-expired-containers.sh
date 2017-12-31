#!/bin/sh

for CONTAINER in $(sudo docker container ls --all --filter status=created --filter label=expiry --quiet)
do
    if [ $(sudo docker container inspect ${CONTAINER} --format "{{ .Config.Labels.expiry }}") -lt $(date +%s) ]
    then
        sudo docker container rm --volumes ${CONTAINER}
    fi
done &&
    for CONTAINER in $(sudo docker container ls --all --filter status=exited --filter label=expiry --quiet)
    do
        if [ $(sudo docker container inspect ${CONTAINER} --format "{{ .Config.Labels.expiry }}") -lt $(date +%s) ]
        then
            sudo docker container rm --volumes ${CONTAINER}
        fi
    done &&
    for CONTAINER in $(sudo docker container ls --all --filter status=dead --filter label=expiry --quiet)
    do
        if [ $(sudo docker container inspect ${CONTAINER} --format "{{ .Config.Labels.expiry }}") -lt $(date +%s) ]
        then
            sudo docker container rm --volumes ${CONTAINER}
        fi
    done