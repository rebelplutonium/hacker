#!/bin/sh

CLOUD9_PORT=16845 &&
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
            --origin-organization)
                export ORIGIN_ORGANIZATION="${2}" &&
                    shift 2
            ;;
            --origin-repository)
                export ORIGIN_REPOSITORY="${2}" &&
                    shift 2
            ;;
            --host-name)
                export HOST_NAME="${2}" &&
                    shift 2
            ;;
            --host-port)
                export HOST_PORT="${2}" &&
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
    CIDFILE=$(mktemp) &&
    rm -f ${CIDFILE} &&
    cleanup(){
        docker container stop $(cat ${CIDFILE}) &&
            docker container rm --volumes $(cat ${CIDFILE}) &&
            rm -f ${CIDFILE}
    } &&
    trap cleanup EXIT &&
    docker \
        container \
        create \
        --cidfile ${CIDFILE} \
        --interactive \
        --tty \
        --rm \
        --env PROJECT_NAME="${PROJECT_NAME}" \
        --env CLOUD9_PORT="${CLOUD9_PORT}" \
        --env GPG_SECRET_KEY="${GPG_SECRET_KEY}" \
        --env GPG2_SECRET_KEY="${GPG2_SECRET_KEY}" \
        --env GPG_OWNER_TRUST="${GPG_OWNER_TRUST}" \
        --env GPG2_OWNER_TRUST="${GPG2_OWNER_TRUST}" \
        --env GPG_KEY_ID="${GPG_KEY_ID}" \
        --env USER_EMAIL="${USER_EMAIL}" \
        rebelplutonium/secret-editor:0.0.0 &&
    docker network connect --alias ${EXTERNAL_NETWORK_NAME} $(cat ${CIDFILE}) &&
    docker container start $(cat ${CIDFILE})
