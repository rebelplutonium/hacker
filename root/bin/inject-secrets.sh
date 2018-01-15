#!/bin/sh

pass show upstream.id_rsa > ${HOME}/.ssh/upstream.id_rsa &&
    pass show report.id_rsa > ${HOME}/.ssh/report.id_rsa &&
    (
        pass show aws-access-key-id &&
            pass show aws-secret-access-key &&
            echo us-east-1 &&
            echo text
    ) | aws configure