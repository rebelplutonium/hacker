#!/bin/sh

TEMP=$(mktemp -d /opt/docker/workspace/XXXXXXXX) &&
    echo ${TEMP} &&
    mkdir ${TEMP}/{master,alpha,beta} &&
    git -C ${TEMP}/master init --bare &&
    git -C ${TEMP}/alpha init &&
    git -C ${TEMP}/alpha remote add origin ${TEMP}/master &&
    git -C ${TEMP}/alpha config user.name "alpha" &&
    git -C ${TEMP}/alpha config user.email "alpha@mail" &&
    echo 0 > ${TEMP}/alpha/counter &&
    uuidgen > ${TEMP}/alpha/uuid &&
    git -C ${TEMP}/alpha add counter &&
    git -C ${TEMP}/alpha add uuid &&
    git -C ${TEMP}/alpha commit -am "init" &&
    git -C ${TEMP}/alpha push origin master &&
    git -C ${TEMP}/beta init &&
    git -C ${TEMP}/beta remote add origin ${TEMP}/master &&
    git -C ${TEMP}/beta config user.name "beta" &&
    git -C ${TEMP}/beta config user.email "beta@mail" &&
    git -C ${TEMP}/beta fetch origin master &&
    git -C ${TEMP}/beta checkout master &&
    echo atlanta > ${TEMP}/alpha/uuid &&
    git -C ${TEMP}/alpha commit -am "alpha one one" &&
    echo albany > ${TEMP}/alpha/uuid &&
    git -C ${TEMP}/alpha commit -am "alpha one two" &&
    git -C ${TEMP}/alpha push origin master &&
    echo birmingham > ${TEMP}/beta/uuid &&
    git -C ${TEMP}/beta commit -am "beta one one" &&
    echo berkeley > ${TEMP}/beta/uuid &&
    git -C ${TEMP}/beta commit -am "beta one two" &&
    echo bristol > ${TEMP}/beta/uuid &&
    git -C ${TEMP}/beta commit -am "beta one three" &&
    git -C ${TEMP}/beta fetch origin master &&
    echo ${TEMP}