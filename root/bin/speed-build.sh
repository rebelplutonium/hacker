#!/bin/sh

cd $(mktemp -d /srv/docker/workspace/XXXXXXXX) &&
    git init &&
    git remote add origin https://github.com/nextmoose/${1}.git &&
    git fetch origin ${2} &&
    git checkout origin/${2} &&
    IIDFILE=$(mktemp /srv/docker/images/XXXXXXXX) &&
    rm -f ${IIDFILE} &&
    time docker image build --label expiry=$(($(date +%s)+60*60*24*7)) --iidfile ${IIDFILE} --tag rebelplutonium/${1}:${3} .