#!/bin/sh

export PROJECT_NAME=hacker &&
    export CLOUD9_PORT=10380 &&
    while [ ${#} -gt 0 ]
    do
        case ${1} in
            --project-name)
                export PROJECT_NAME="${2}" &&
                    shift 2
            ;;
            --cloud9-port)
                export CLOUD9_PORT="${2}" &&
                    shift 2
            ;;
            *)
                echo Unsupported Option &&
                    echo ${0} &&
                    echo ${@} &&
                    exit 64
            ;;
        esac
    done &&
    cd $(mktemp -d /srv/docker/workspace/XXXXXXXX) &&
    CIDFILE=$(generate-container-id) &&
    export PROJECT_NAME="${PROJECT_NAME}" &&
    docker \
        container \
        create \
        --cidfile ${CIDFILE} \
        --env PROJECT_NAME="${PROJECT_NAME}" \
        --env CLOUD9_PORT="${CLOUD9_PORT}" \
        --env UPSTREAM_ID_RSA="$(pass show upstream.id_rsa)" \
        --env UPSTREAM_ORGANIZATION=rebelplutonium \
        --env UPSTREAM_REPOSITORY=hacker \
        --env ORIGIN_ID_RSA="$(pass show upstream.id_rsa)" \
        --env ORIGIN_ORGANIZATION=nextmoose \
        --env ORIGIN_REPOSITORY=hacker \
        --env REPORT_ID_RSA="$(pass show report.id_rsa)" \
        --env REPORT_ORGANIZATION=rebelplutonium \
        --env REPORT_REPOSITORY=hacker \
        --env USER_NAME="${USER_NAME}" \
        --env USER_EMAIL="${USER_EMAL}" \
        --env HOST_NAME=github.com \
        --env HOST_PORT=22 \
        --env MASTER_BRANCH=master \
        rebelplutonium/github:0.0.4 &&
    docker network connect --alias ${PROJECT_NAME} ${EXTERNAL_NETWORK_NAME} $(cat ${CIDFILE}) &&
    docker container start $(cat ${CIDFILE})