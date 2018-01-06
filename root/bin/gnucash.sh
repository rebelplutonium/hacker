#!/bin/sh

SECURITY_GROUP=$(uuidgen) &&
    KEY_NAME=$(uuidgen) &&
    KEY_FILE=$(mktemp ${HOME}/.ssh/XXXXXXXX.id_rsa) &&
    rm -f ${KEY_FILE} &&
    cleanup(){
        rm -f ${KEY_FILE} ${KEY_FILE}.pub &&
            aws \
                ec2 \
                wait \
                instance-terminated \
                --instance-ids $(aws \
                    ec2 \
                    terminate-instances \
                    --instance-ids $(aws ec2 describe-instances --filters Name=tag:moniker,Values=lieutenant Name=instance-state-name,Values=running --query "Reservations[0].Instances[*].InstanceId" --output text) \
                    --query "TerminatingInstances[*].InstanceId" \
                    --output text) &&
            sed -i "s%Host lieutenant-ec2%# Host lieutenant-ec2%" ${HOME}/.ssh/config &&
            sed -i "s%HostName $(aws ec2 describe-instances --filter Name=tag:moniker,Values=lieutenant Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].PublicIpAddress" --output text)%# HostName \${LIEUTENANT_PUBLIC_IP_ADDRESS}%" ${HOME}/.ssh/config  &&
            sed -i "s%User ec2-user%# User ec2-user%" ${HOME}/.ssh/config &&
            sed -i "s%IdentityFile ${KEY_FILE}%# IdentityFile \${LIEUTENANT_IDENTITY_FILE}%" ${HOME}/.ssh/config &&
            aws ec2 delete-security-group --group-name ${SECURITY_GROUP} &&
            aws ec2 delete-key-pair --key-name ${KEY_NAME} &&
            rm -rf /opt/docker/workspace/lieutenant
    } &&
    trap cleanup EXIT &&
    ssh-keygen -f ${KEY_FILE} -C "temporary lieutenant-ec2" -P "" &&
    aws \
        ec2 \
        wait \
        instance-running \
        --instance-ids $(aws \
            ec2 \
            run-instances \
            --image-id ami-55ef662f \
            --security-group-ids $(aws ec2 create-security-group --group-name ${SECURITY_GROUP} --description "security group for the lieutenant environment in EC2" --query "GroupId" --output text) \
            --count 1 \
            --instance-type t2.micro \
            --key-name $(aws ec2 import-key-pair --key-name ${KEY_NAME} --public-key-material "$(cat ${KEY_FILE}.pub)" --query "KeyName" --output text) \
            --tag-specifications "ResourceType=instance,Tags=[{Key=moniker,Value=lieutenant}]" \
            --query "Instances[0].InstanceId" \
            --output text) &&
    DEVICE=$(aws \
        ec2 \
        attach-volume \
        --device /dev/sdh \
        --volume-id $(aws ec2 describe-volumes --filters Name=tag:moniker,Values=lieutenant --query "Volumes[*].VolumeId" --output text) \
        --instance-id $(aws ec2 describe-instances --filters Name=tag:moniker,Values=lieutenant Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text) \
        --query "Device" \
        --output text) &&
    aws ec2 authorize-security-group-ingress --group-name ${SECURITY_GROUP} --protocol tcp --port 22 --cidr 0.0.0.0/0 &&
    sed -i "s%# Host lieutenant-ec2%Host lieutenant-ec2%" ${HOME}/.ssh/config &&
    sed -i "s%# HostName \${LIEUTENANT_PUBLIC_IP_ADDRESS}%HostName $(aws ec2 describe-instances --filter Name=tag:moniker,Values=lieutenant Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].PublicIpAddress" --output text)%" ${HOME}/.ssh/config &&
    sed -i "s%# User ec2-user%User ec2-user%" ${HOME}/.ssh/config &&
    sed -i "s%# IdentityFile \${LIEUTENANT_IDENTITY_FILE}%IdentityFile ${KEY_FILE}%" ${HOME}/.ssh/config &&
    sleep 15s &&
    ssh-keyscan $(aws ec2 describe-instances --filter Name=tag:moniker,Values=lieutenant Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].PublicIpAddress" --output text) >> ${HOME}/.ssh/known_hosts &&
    ssh lieutenant-ec2 sudo mkdir /data &&
    ssh lieutenant-ec2 sudo mount ${DEVICE} /data &&
    echo "find /dev/disk/by-uuid/ -mindepth 1 | while read FILE; do [ \$(readlink -f \${FILE}) == \"${DEVICE}\" ] && basename \${FILE} ; done | while read UUID; do echo \"UUID=\${UUID}       /data   ext4    defaults,nofail        0       2\" | sudo tee --append /etc/fstab ; done" | ssh lieutenant-ec2 sh &&
    mkdir /opt/docker/workspace/lieutenant &&
    sshfs -o allow_other lieutenant-ec2:/data /opt/docker/workspace/lieutenant &&
    /usr/bin/gnucash lieutenant/gnucash/gnucash.gnucash