#!/bin/sh

docker container ls --all --quiet --filter status=exited | while read CONTAINER
do
    if [ $(date --date $(docker container inspect --format "{{.State.FinishedAt}}" ${CONTAINER}) +%s) -lt $(($(date +%s)-${AGE_DELTA})) ]
    then
        echo ${CONTAINER}
    fi
done &&
    docker container ls --all --quiet --filter status=dead | while read CONTAINER
    do
        if [ $(date --date $(docker container inspect --format "{{.State.FinishedAt}}" ${CONTAINER}) +%s) -lt $(($(date +%s)-${AGE_DELTA})) ]
        then
            echo ${CONTAINER}
        fi
    done