#!/bin/sh

xhost +local: &&
    IDS=$(mktemp -d) &&
    mkdir ${IDS}/containers &&
    mkdir ${IDS}/networks &&
    mkdir ${IDS}/volumes &&
    cleanup(){
        ls -1 ${IDS}/containers | while read FILE
        do
            sudo /usr/bin/docker container stop $(cat ${IDS}/containers/${FILE}) &&
                sudo /usr/bin/docker container rm --volumes $(cat ${IDS}/containers/${FILE})
        done &&
        ls -1 ${IDS}/networks | while read FILE
        do
            sudo /usr/bin/docker network rm $(cat ${IDS}/networks/${FILE})
        done &&
        ls -1 ${IDS}/volumes | while read FILE
        do
            sudo /usr/bin/docker volume rm $(cat ${IDS}/volumes/${FILE})
        done &&
        rm -rf ${IDS} &&
        xhost
    } &&
    trap cleanup EXIT &&
    while [ ${#} -gt 0 ]
    do
        case ${1} in
            --hacker-version)
                HACKER_VERSION="${2}" &&
                    shift 2
            ;;
            --use-versioned-hacker-secrets)
                USE_VERSIONED_HACKER_SECRETS=yes &&
                    shift
            ;;
            *)
                echo Unknown Option &&
                    echo ${0} &&
                    echo ${@} &&
                    exit 64
            ;;
        esac
    done &&
    sudo /usr/bin/docker volume create --label expiry=$(($(date +%s)+60*60*24*7)) > ${IDS}/volumes/storage &&
    sudo /usr/bin/docker volume create --label expiry=$(($(date +%s)+60*60*24*7)) > ${IDS}/volumes/docker &&
    sudo /usr/bin/docker network create --label expiry=$(($(date +%s)+60*60*24*7)) $(uuidgen) > ${IDS}/networks/main &&
    export ORIGIN_ID_RSA="$(cat private/origin.id_rsa)" &&
    export GPG_SECRET_KEY="$(cat private/gpg_secret_key)" &&
    export GPG2_SECRET_KEY="$(cat private/gpg2_secret_key)" &&
    export GPG_OWNER_TRUST="$(cat private/gpg_owner_trust)" &&
    export GPG2_OWNER_TRUST="$(cat private/gpg2_owner_trust)" &&
    sudo \
        --preserve-env \
        docker \
        container \
        create \
        --interactive \
        --tty \
        --cidfile ${IDS}/containers/hacker \
        --env PROJECT_NAME="my-hacker" \
        --env CLOUD9_PORT="10379" \
        --env DISPLAY="${DISPLAY}" \
        --env EXTERNAL_NETWORK_NAME="$(cat ${IDS}/networks/main)" \
        --env USER_NAME="Emory Merryman" \
        --env USER_EMAIL="emory.merryman@gmail.com" \
        --env ORIGIN_ID_RSA \
        --env GPG_SECRET_KEY \
        --env GPG2_SECRET_KEY \
        --env GPG_OWNER_TRUST \
        --env GPG2_OWNER_TRUST \
        --env GPG_KEY_ID=D65D3F8C \
        --env SECRETS_ORIGIN_ORGANIZATION=nextmoose \
        --env SECRETS_ORIGIN_REPOSITORY=secrets \
        --env EXTERNAL_DOCKER_VOLUME=$(cat ${IDS}/volumes/docker) \
        --privileged \
        --mount type=bind,source=/tmp/.X11-unix/X0,destination=/tmp/.X11-unix/X0,readonly=true \
        --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock,readonly=true \
        --mount type=bind,source=/,destination=/srv/host,readonly=true \
        --mount type=bind,source=/media,destination=/srv/media,readonly=false \
        --mount type=bind,source=/home,destination=/srv/home,readonly=false \
        --mount type=volume,source=$(cat ${IDS}/volumes/storage),destination=/srv/storage,readonly=false \
        --mount type=volume,source=$(cat ${IDS}/volumes/docker),destination=/srv/docker,readonly=false \
        --label expiry=$(($(date +%s)+60*60*24*7)) \
        rebelplutonium/hacker:${HACKER_VERSION} &&
    sudo \
        --preserve-env \
        docker \
        container \
        create \
        --cidfile ${IDS}/containers/browser \
        --mount type=bind,source=/tmp/.X11-unix/X0,destination=/tmp/.X11-unix/X0,readonly=true \
        --mount type=volume,source=$(cat ${IDS}/volumes/storage),destination=/srv/storage,readonly=false \
        --env DISPLAY=${DISPLAY} \
        --shm-size 256m \
        --label expiry=$(($(date +%s)+60*60*24*7)) \
        rebelplutonium/browser:0.0.0 \
            http://my-hacker:10379 &&
    sudo /usr/bin/docker network connect $(cat ${IDS}/networks/main) $(cat ${IDS}/containers/browser) &&
    sudo /usr/bin/docker network connect --alias my-hacker $(cat ${IDS}/networks/main) $(cat ${IDS}/containers/hacker) &&
    sudo /usr/bin/docker container start $(cat ${IDS}/containers/browser) &&
    sudo /usr/bin/docker container start --interactive $(cat ${IDS}/containers/hacker)