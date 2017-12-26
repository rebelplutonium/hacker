#!/bin/sh


docker volume ls --quiet --filter dangling=false | head -n 10 | while read VOLUME
do
    (cat <<EOF
CUTOFF=$(($(date +%s)-60*60*24*7*13)) &&
    find /volume -mindepth 1 | while read FILE1
    do
        stat -c %X "\${FILE1}"
    done | sort -u | tail -n 1 | while read LAST_ACCESSED
    do
        [ \${LAST_ACCESSED} -lt \${CUTOFF} ] &&
            find /volume -mindepth 1 | while read FILE2
            do
                stat -c %X "\${FILE2}"
            done | sort -u | tail -n 1 | while read LAST_MODIFIED
            do
                [ \${LAST_MODIFIED} -lt \${CUTOFF} ] &&
                    find /volume -mindepth 1 | while read FILE3
                    do
                        stat -c %X "\${FILE3}"
                    done | sort -u | tail -n 1 | while read LAST_CHANGED
                    do
                        [ \${LAST_CHANGED} -lt \${CUTOFF} ] &&
                            echo \${VOLUME}
                    done
            done
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
        sh | while read VOLUME
        do
            docker container ls --all --filter volume=${VOLUME}
        done
done
