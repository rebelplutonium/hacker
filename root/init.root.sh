#!/bin/sh

mkdir /srv/ids/{containers,images,networks,volumes} &&
    chown user:user /srv/ids/{containers,images,networks,volumes}