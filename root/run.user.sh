#!/bin/sh

pip install awscli --upgrade --user &&
    echo "export PATH=\${HOME}/.local/bin:\${PATH}" >> ${HOME}/.bashrc &&
    mkdir /home/user/.ssh &&
    chmod 0700 /home/user/.ssh &&
    touch /home/user/.ssh/{known_hosts,config,origin.id_rsa,upstream.id_rsa,report.id_rsa,lieutenant-ec2.id_rsa,lieutenant.id_rsa,pavillion.id_rsa} &&
    chmod 0644 /home/user/.ssh/known_hosts &&
    chmod 0600 /home/user/.ssh/{config,origin.id_rsa,upstream.id_rsa,report.id_rsa,lieutenant-ec2.id_rsa,lieutenant.id_rsa,pavillion.id_rsa} &&
    mkdir /home/user/bin &&
    mkdir /opt/docker/workspace/projects