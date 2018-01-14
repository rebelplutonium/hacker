#!/bin/sh

IDFILE=$(mktemp /srv/docker/${1}/XXXXXXXX) &&
    rm -f ${IDFILE} &&
    echo ${IDFILE}