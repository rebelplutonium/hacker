#!/bin/sh

ls -1 /srv/ids/containers | while read FILE
do
    sudo /usr/bin/docker container stop $(cat /srv/ids/containers/${FILE}) &&
        sudo /usr/bin/docker container rm --volumes $(cat /srv/ids/containers/${FILE}) &&
        rm -f /srv/ids/${FILE}
done &&
    ls -1 /srv/ids/images | while read FILE
    do
        sudo /usr/bin/docker image rm $(cat /srv/ids/images/${FILE}) &&
            rm -f /srv/ids/${FILE}
    done &&
    ls -1 /srv/ids/networks | while read FILE
    do
        sudo /usr/bin/docker network rm $(cat /srv/ids/networks/${FILE}) &&
            rm -f /srv/ids/${FILE}
    done &&
    ls -1 /srv/ids/volumes | while read FILE
    do
        sudo /usr/bin/docker volume rm $(cat /srv/ids/volumes/${FILE}) &&
            rm -f /srv/ids/${FILE}
    done
        