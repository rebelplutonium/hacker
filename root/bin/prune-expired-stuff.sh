#!/bin/sh

prune-expired-containers &&
    prune-expired-images &&
    prune-expired-volumes &&
    prune-expired-networks