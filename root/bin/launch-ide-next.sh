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
            --upstream-id-rsa)
                export UPSTREAM_ID_RSA="${2}" &&
                    shift 2
            ;;
            --upstream-organization)
                export UPSTREAM_REPOSITORY="${2}" &&
                    shift 2
            ;;
            --upstream-repository)
                export UPSTREAM_REPOSITORY="${2}" &&
                    shift 2
            ;;
            --origin-id-rsa)
                export ORIGIN_ID_RSA="${2}" &&
                    shift 2
            ;;
            --origin-organization)
                export UPSTREAM_REPOSITORY="${2}" &&
                    shift 2
            ;;
            --origin-repository)
                export UPSTREAM_REPOSITORY="${2}" &&
                    shift 2
            ;;
            --report-id-rsa)
                export REPORT_ID_RSA="${2}" &&
                    shift 2
            ;;
            --report-organization)
                export UPSTREAM_REPOSITORY="${2}" &&
                    shift 2
            ;;
            --report-repository)
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
            --checkout-branch)
                export CHECKOUT_BRANCH="${2}" &&
                    shift 2
            ;;
            --gpg-secret-key)
                export GPG_SECRET_KEY="${2}" &&
                    shift 2
            ;;
            --gpg2-secret-key)
                export GPG2_SECRET_KEY="${2}" &&
                    shift 2
            ;;
            --gpg-owner-trust)
                export GPG_OWNER_TRUST="${2}" &&
                    shift 2
            ;;
            --gpg2-owner-trust)
                export GPG2_OWNER_TRUST="${2}" &&
                    shift 2
            ;;
            --gpg-key-id)
                export GPG_KEY_ID="${2}" &&
                    shift 2
            ;;
            --user-name)
                export USER_NAME="${2}" &&
                    shift 2
            ;;
            --user-email)
                export USER_EMAIL="${2}" &&
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
        --env UPSTREAM_ID_RSA="$(pass show ${UPSTREAM_ID_RSA})" \
        --env UPSTREAM_ORGANIZATION="${UPSTREAM_ORGANIZATION}" \
        --env UPSTREAM_REPOSITORY="${UPSTREAM_REPOSITORY}" \
        --env ORIGIN_ID_RSA="$(pass show ${ORIGIN_ID_RSA})" \
        --env ORIGIN_ORGANIZATION="${ORIGIN_ORGANIZATION}" \
        --env ORIGIN_REPOSITORY="${ORIGIN_REPOSITORY}" \
        --env REPORT_ID_RSA="$(pass show ${REPORT_ID_RSA})" \
        --env REPORT_ORGANIZATION="${REPORT_ORGANIZATION}" \
        --env REPORT_REPOSITORY="${REPORT_REPOSITORY}" \
        --env USER_NAME="${USER_NAME}" \
        --env USER_EMAIL="${USER_EMAL}" \
        --env HOST_NAME="${HOST_NAME}" \
        --env HOST_PORT="${HOST_PORT}" \
        --env MASTER_BRANCH="${MASTER_BRANCH}" \
        --env CHECKOUT_BRANCH="${CHECKOUT_BRANCH}" \
        --env GPG_SECRET_KEY="$(pass show ${GPG_SECRET_KEY})" \
        --env GPG2_SECRET_KEY="$(pass show ${GPG2_SECRET_KEY})" \
        --env GPG_OWNER_TRUST="$(pass show ${GPG_OWNER_TRUST})" \
        --env GPG2_OWNER_TRUST="$(pass show ${GPG2_OWNER_TRUST})" \
        --env GPG_KEY_ID="$(pass show ${GPG_KEY_ID})" \
        --env USER_NAME="${USER_NAME}" \
        --env USER_EMAIL="${USER_EMAIL}" \
        rebelplutonium/github:0.0.8 &&
    docker network connect --alias ${PROJECT_NAME} ${EXTERNAL_NETWORK_NAME} $(cat ${CIDFILE}) &&
    docker container start $(cat ${CIDFILE})