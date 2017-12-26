#!/bin/sh

docker volume ls --quiet --filter dangling=true | while read VOLUME
do
    [ "<no value>" == "$(docker volume inspect --format "{{ .Labels.expiry }}" ${VOLUME})" ] &&
        (cat <<EOF
AGE_CUTOFF=$(($(date +%s)-${AGE_DELTA}))
    find /volume -mindepth 1 | while read FILE1
    do
        stat -c %X "\${FILE1}"
    done | sort -u | tail -n 1 | while read LAST_ACCESSED
    do
        if [ \${LAST_ACCESSED} -gt \${AGE_CUTOFF} ]
        then
            echo \${VOLUME} &&
                exit 0
        fi
    done &&
    find /volume -mindepth 1 | while read FILE1
    do
        stat -c %Y "\${FILE1}"
    done | sort -u | tail -n 1 | while read LAST_MODIFIED
    do
        if [ \${LAST_MODIFIED} -gt \${AGE_CUTOFF} ]
        then
            echo \${VOLUME} &&
                exit 0
        fi
    done &&
    find /volume -mindepth 1 | while read FILE1
    do
        stat -c %Z "\${FILE1}"
    done | sort -u | tail -n 1 | while read LAST_CHANGED
    do
        if [ \${LAST_CHANGED} -gt \${AGE_CUTOFF} ]
        then
            echo \${VOLUME} &&
                exit 0
        fi
    done
EOF
        ) | docker \
    container \
    run \
    --interactive \
    --rm \
    --label expiry=$(($(date +%s)+60*60*24*7)) \
    --volume ${VOLUME}:/volume:ro \
    --env VOLUME=${VOLUME} \
    alpine:3.4 \
        sh
done