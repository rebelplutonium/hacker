#!/bin/sh

for NETWORK in $(sudo docker network ls --filter label=expiry --quiet)
do
    if [ $(sudo docker network inspect ${NETWORK} --format "{{ .Labels.expiry }}") -lt $(date +%s) ]
    then
        sudo docker network rm ${NETWORK}
    fi
done