#!/bin/sh

CIDFILE=$(mktemp /srv/ids/containers/XXXXXXXX) &&
    rm -f ${CIDFILE} &&
    sudo \
        --preserve-env \
        /usr/bin/docker \
        --interactive \
        --tty \
        --rm \
        --label expiry=$(($(date +%s)+60*60*24*7)) \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --volume ${EXTERNAL_IDS_VOLUME}:/srv/ids \
	docker:17.12.0 \
        "${@}" &&
   sudo \
	--preserve-env \
	/usr/bin/docker \
	docker:17.12.0 \
	start \
	$(cat ${CIDFILE})
