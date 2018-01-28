#!/bin/sh

while [ ${#} -gt 0 ]
do
    case ${1} in
        --project-name)
            export PROJECT_NAME="${2}" &&
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
    if [ -z "${PROJECT_NAME}" ]
    then
        echo Must specify a project name &&
            exit 65
    fi &&
    launch-ide-next \
        --host-name github.com \
        --host-port 22 \
        --master-branch master \
        --upstream-id-rsa upstream.id_rsa \
        --upstream-organization rebelplutonium \
        --upstream-repository hacker \
        --origin-id-rsa origin.id_rsa \
        --origin-organization nextmoose \
        --origin-repository hacker \
        --report-id-rsa report.id_rsa \
        --report-organization rebelplutonium \
        --report-repository hacker \
        --cloud9-port 10380 \
        --gpg-secret-key gpg.secret.key \
        --gpg2-secret-key gpg2.secret.key \
        --gpg-owner-trust gpg.owner.trust \
        --gpg2-owner-trust gpg2.owner.trust \
        --gpg-key-id gpg.key.id \
        --project-name "${PROJECT_NAME}"