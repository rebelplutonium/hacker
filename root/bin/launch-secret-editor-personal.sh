#!/bin/sh

launch-secret-editor \
    --origin-organization desertedscorpion \
    --origin-repository passwordstore \
    --host-name github.com \
    --host-port 22 \
    --user-name "${USER_NAME}" \
    --user-email "${USER_EMAIL}" \
    --read-write