#!/bin/sh

mkdir /srv/docker/{containers,images,networks,volumes,workspace} &&
    chown user:user /srv/docker/{containers,images,networks,volumes,workspace}