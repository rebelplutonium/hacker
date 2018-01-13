#!/bin/sh

ls -1 ${HOME}/ids/containers | while read FILE
do
    sudo /usr/bin/docker container stop $(cat ${HOME}/ids/containers/${FILE}) &&
        sudo /usr/bin/docker container rm --volumes $(cat ${HOME}/ids/containers/${FILE})
done &&
    ls -1 ${HOME}/ids/images | while read FILE
    do
        sudo /usr/bin/docker image rm $(cat ${HOME}/ids/images/${FILE})
    done &&
    ls -1 ${HOME}/ids/networks | while read FILE
    do
        sudo /usr/bin/docker network rm $(cat ${HOME}/ids/networks/${FILE})
    done &&
    ls -1 ${HOME}/ids/volumes | while read FILE
    do
        sudo /usr/bin/docker volume rm $(cat ${HOME}/ids/volumes/${FILE})
    done &&
    rm -rf ${HOME}/ids
        