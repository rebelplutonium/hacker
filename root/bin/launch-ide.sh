#!/bin/sh

export PROJECT_NAME=hacker &&
    export CLOUD9_PORT=10380 &&
    export HOST_NAME=github.com &&
    export HOST_PORT=22 &&
    export MASTER_BRANCH=master &&
    while [ ${#} -gt 0 ]
    do
        case ${1} in
            --host-name)
                export HOST_NAME="${2}" &&
                    shift 2
            ;;
            --host-port)
                export HOST_PORT="${2}" &&
                    shift 2
            ;;
            --master-branch)
                export MASTER_BRANCH="${2}" &&
                    shift 2
            ;;
            --upstream-repository)
                export UPSTREAM_REPOSITORY="${2}" &&
                    shift 2
            ;;
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
        --env UPSTREAM_REPOSITORY="${UPSTREAM_REPOSITORY}" \
        --env ORIGIN_ID_RSA="$(pass show upstream.id_rsa)" \
        --env ORIGIN_ORGANIZATION=nextmoose \
        --env ORIGIN_REPOSITORY="${UPSTREAM_REPOSITORY}" \
        --env REPORT_ID_RSA="$(pass show report.id_rsa)" \
        --env REPORT_ORGANIZATION=rebelplutonium \
        --env REPORT_REPOSITORY="${UPSTREAM_REPOSITORY}" \
        --env USER_NAME="${USER_NAME}" \
        --env USER_EMAIL="${USER_EMAL}" \
        --env HOST_NAME="${HOST_NAME}" \
        --env HOST_PORT="${HOST_PORT}" \
        --env MASTER_BRANCH="${MASTER_BRANCH}" \
        rebelplutonium/github:0.0.4 &&
    docker network connect --alias ${PROJECT_NAME} ${EXTERNAL_NETWORK_NAME} $(cat ${CIDFILE}) &&
    docker container start $(cat ${CIDFILE})