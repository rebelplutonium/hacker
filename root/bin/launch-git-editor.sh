#!/bin/sh

while [ ${#} -gt 0 ]
do
    case ${1} in
        --project-name)
            export PROJECT_NAME="${2}" &&
                shift 2
        ;;
        --upstream-organization)
            export UPSTREAM_ORGANIZATION="${2}" &&
                shift 2
        ;;
        --upstream-repository)
            export UPSTREAM_REPOSITORY="${2}" &&
                shift 2
        ;;
        --origin-organization)
            export ORIGIN_ORGANIZATION="${2}" &&
                shift 2
        ;;
        --origin-repository)
            export ORIGIN_REPOSITORY="${2}" &&
                shift 2
        ;;
        --report-organization)
            export ORIGIN_ORGANIZATION="${2}" &&
                shift 2
        ;;
        --report-repository)
            export ORIGIN_REPOSITORY="${2}" &&
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
    export EXTERNAL_NETWORK_NAME=00997361c2ff4d448317444eaf3ec0f01564483b9c7c3861a5a6ea00e23d2032 &&
    export UPSTREAM_ID_RSA="$(pass show upstream.id_rsa)" &&
    export ORIGIN_ID_RSA="$(pass show origin.id_rsa)" &&
    export REPORT_ID_RSA="$(pass show report.id_rsa)" &&
    export USER_NAME \
    export USER_EMAIL \
    CIDFILE=$(mktemp /srv/ids/containers/XXXXXXXX) &&
    rm -f ${CIDFILE} &&
    docker \
        container \
        create \
        --cidfile ${CIDFILE} \
        --env PROJECT_NAME \
        --env CLOUD9_PORT=10380 \
        --env UPSTREAM_ID_RSA \
        --env UPSTREAM_ORGANIZATION \
        --env UPSTREAM_REPOSITORY \
        --env ORIGIN_ID_RSA \
        --env ORIGIN_ORGANIZATION \
        --env ORIGIN_REPOSITORY \
        --env REPORT_ID_RSA \
        --env REPORT_ORGANIZATION \
        --env REPORT_REPOSITORY \
        --env MASTER_BRANCH=master \
        --env USER_NAME \
        --env USER_EMAIL \
        --env HOST_NAME=github.com \
        --env HOST_PORT=22 \
        rebelplutonium/github:0.0.4 &&
    docker network connect --alias ${PROJECT_NAME} ${EXTERNAL_NETWORK_NAME} $(cat ${CIDFILE}) &&
    docker container start $(cat ${CIDFILE})