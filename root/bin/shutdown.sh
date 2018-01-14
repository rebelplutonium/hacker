#!/bin/sh

ps all | grep "node /opt/docker/c9sdk/server.js --listen 0.0.0.0 -w /opt/docker/workspace -p " | head -n 1 | sed -e "s#^[0-9]*\s*[0-9]*\s*##" | cut -f1 -d " " | while read PID
do
    kill ${PID}
done