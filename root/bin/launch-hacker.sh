#!/bin/sh

export CLOUD9_PORT=10379 &&
    while [ ${#} -gt 0 ]
    do
        case "${1}" in
            --project-name)
                export PROJECT_NAME="${2}" &&
                    shift 2
            ;;
            --cloud9-port)
                export CLOUD9_PORT="${2}" &&
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
            --origin-id-rsa)
                export ORIGIN_ID_RSA="${2}" &&
                    shift 2
            ;;
            --gpg-secret-key)
                export GPG_SECRET_KEY="${2}" &&
                    shift 2
            ;;
            --gpg2-secret-eky)
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
            --secrets-organization)
                export SECRETS_ORIGIN_ORGANIZATION="${2}" &&
                    shift 2
            ;;
            --secrets-repository)
                export SECRETS_REPOSITORY="${2}" &&
                    shift 2
            ;;
            --hacker-version)
                export HACKER_VERSION="${2}" &&
                    shift 2
            ;;
            *)
                echo Unknown Option &&
                    echo ${0} &&
                    echo ${@} &&
                    exit 64
            ;;
        esac
    done &&
    CIDFILE=$(generate-container-id) &&
    docker \
        container \
        create \
        --interactive \
        --tty \
        --cidfile ${CIDFILE} \
        --env PROJECT_NAME="${PROJECT_NAME}" \
        --env CLOUD9_PORT="${CLOUD9_PORT}" \
        --env DISPLAY="${DISPLAY}" \
        --env EXTERNAL_NETWORK_NAME="${EXTERNAL_NETWORK_NAME}" \
        --env USER_NAME="${USER_NAME}" \
        --env USER_EMAIL="${USER_EMAIL}" \
        --env ORIGIN_ID_RSA="$(pass show ${ORIGIN_ID_RSA})" \
        --env GPG_SECRET_KEY="$(pass show ${GPG_SECRET_KEY})" \
        --env GPG2_SECRET_KEY="$(pass show ${GPG2_SECRET_KEY})" \
        --env GPG_OWNER_TRUST="$(pass show ${GPG_OWNER_TRUST})" \
        --env GPG2_OWNER_TRUST="$(pass show ${GPG2_OWNER_TRUST})" \
        --env GPG_KEY_ID="$(pass show ${GPG_KEY_ID})" \
        --env SECRETS_ORIGIN_ORGANIZATION="${SECRETS_ORGANIZATION}" \
        --env SECRETS_ORIGIN_REPOSITORY="${SECRETS_REPOSITORY}" \
        --env EXTERNAL_DOCKER_VOLUME="${EXTERNAL_DOCKER_VOLUME}" \
        --privileged \
        --mount type=bind,source=/tmp/.X11-unix/X0,destination=/tmp/.X11-unix/X0,readonly=true \
        --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock,readonly=true \
        --mount type=bind,source=/,destination=/srv/host,readonly=true \
        --mount type=bind,source=/media,destination=/srv/media,readonly=false \
        --mount type=bind,source=/home,destination=/srv/home,readonly=false \
         --mount type=volume,source=${EXTERNAL_DOCKER_VOLUME},destination=/srv/docker,readonly=false \
        --label expiry=$(($(date +%s)+60*60*24*7)) \
        rebelplutonium/hacker:${HACKER_VERSION} &&
    docker network connect --alias 