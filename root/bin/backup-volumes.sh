#!/bin/sh

mkdir -p /home/user/.ssh &&
    chmod 0700 /home/user/.ssh &&
    echo "${VOLUMES_BACKUP_PRIVATE_KEY}" > /home/user/.ssh/id_rsa &&
    (cat > /home/user/.ssh/config <<EOF
Host volumes-backup
HostName 54.89.237.209
User ec2-user
IdentityFile ~/.ssh/id_rsa
EOF
    ) &&
    chmod 0600 /home/user/.ssh/config /home/user/.ssh/id_rsa &&
    ssh-keyscan 54.89.237.209 > /home/user/.ssh/known_hosts &&
    ssh volumes-backup 