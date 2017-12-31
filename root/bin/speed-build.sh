#!/bin/sh

cd $(mktemp -d) &&
    git clone https://${HOST_NAME}/${1}/${2}.git &&
    cd ${2} &&
    git checkout origin/${3} &&
    time docker image build --label expiry=${EXPIRY} --tag ${1}/${2}:${4} .