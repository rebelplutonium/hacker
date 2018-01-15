#!/bin/sh

dispose-expired-containers &&
    dispose-expired-images &&
    dispose-expired-networks &&
    dispose-expired-volumes