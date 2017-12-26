#!/bin/sh

docker volume ls --filter dangling=true --quiet | while read VOLUME
do
    if [ "<no value>" == "$(docker volume inspect --format "{{ .Labels.expiry }}" ${VOLUME})" ]
    then
        echo ${VOLUME}
    fi
done