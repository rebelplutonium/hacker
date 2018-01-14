#!/bin/sh

pass show upstream.id_rsa > ${HOME}/.ssh/upstream.id_rsa &&
    pass show report.id_rsa > ${HOME}/.ssh/report.id_rsa