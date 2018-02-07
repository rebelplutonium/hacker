#!/bin/sh

pip install awscli --upgrade --user &&
    echo "export PATH=\${HOME}/.local/bin:\${PATH}" >> ${HOME}/.bashrc &&
    touch /home/user/.ssh/{known_hosts,config,origin.id_rsa,upstream.id_rsa,report.id_rsa} &&
    chmod 0644 /home/user/.ssh/known_hosts &&
    chmod 0600 /home/user/.ssh/{origin.id_rsa,upstream.id_rsa,report.id_rsa} &&
    mkdir /home/user/bin &&
    mkdir /opt/docker/workspace/projects