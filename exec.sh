#!/bin/sh

xhost +local: &&
    IDS=$(mktemp -d) &&
    mkdir ${IDS}/containers &&
    mkdir ${IDS}/networks &&
    mkdir ${IDS}/volumes &&
    cleanup(){
        ls -1 ${IDS}/containers | while read FILE
        do
            sudo /usr/bin/docker stop $(cat ${IDS}/containers/${FILE}) &&
                sudo /usr/bin/docker rm --volumes $(cat ${IDS}/containers/${FILE})
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
            --dockerhub-userid)
                export DOCKERHUB_USER_ID="${2}" &&
                    shift 2
            ;;
            --dockerhub-password)
                export DOCKERHUB_PASSWORD="${2}" &&
                    shift 2
            ;;
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
    if [ ! -z "${DOCKERHUB_USER_ID}" ] && [ ! -z "${DOCKERHUB_PASSWORD}" ]
    then
        sudo /usr/bin/docker login --username ${DOCKERHUB_USER_ID} --password ${DOCKERHUB_PASSWORD}
    fi &&
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
        --volume /tmp/.X11-unix/X0:/tmp/.X11-unix/X0:ro \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro\
        --volume /:/srv/host:ro \
        --volume /media:/srv/media:ro \
        --volume /home:/srv/home:ro \
        --volume $(cat ${IDS}/volumes/storage):/srv/storage \
        --volume $(cat ${IDS}/volumes/docker):/srv/docker \
        --label expiry=$(($(date +%s)+60*60*24*7)) \
        rebelplutonium/hacker:${HACKER_VERSION} &&
    sudo \
        --preserve-env \
        docker \
        create \
        --cidfile ${IDS}/containers/browser \
        --volume /tmp/.X11-unix/X0:/tmp/.X11-unix/X0:ro \
        --volume $(cat ${IDS}/volumes/storage):/srv/storage \
        --volume $(cat ${IDS}/volumes/docker):/srv/docker \
        --env DISPLAY=${DISPLAY} \
        --shm-size 256m \
        --label expiry=$(($(date +%s)+60*60*24*7)) \
        rebelplutonium/browser:0.0.0 \
            http://my-hacker:10379 &&
    sudo /usr/bin/docker network connect $(cat ${IDS}/networks/main) $(cat ${IDS}/containers/browser) &&
    sudo /usr/bin/docker network connect --alias my-hacker $(cat ${IDS}/networks/main) $(cat ${IDS}/containers/hacker) &&
    sudo /usr/bin/docker start $(cat ${IDS}/containers/browser) &&
    sudo /usr/bin/docker start --interactive $(cat ${IDS}/containers/hacker)