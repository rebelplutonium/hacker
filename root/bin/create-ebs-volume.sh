#!/bin/sh

PERM_MONIKER="${1}" &&
    TEMP_MONIKER=$(uuidgen) &&
    DOT_SSH_CONFIG_FILE=$(mktemp ${HOME}/.ssh/config.d/XXXXXXXX) &&
    SECURITY_GROUP=$(uuidgen) &&
    KEY_NAME=$(uuidgen) &&
    KEY_FILE=$(mktemp ${HOME}/.ssh/XXXXXXXX.id_rsa) &&
    rm -f ${KEY_FILE} &&
    aws \
        ec2 \
        wait \
        volume-available \
            --volume-ids $(aws \
                ec2 \
                create-volume \
                --availability-zone $(aws ec2 describe-availability-zones --query "AvailabilityZones[0].ZoneName") \
                --size 5 \
                --tag-specifications "ResourceType=volume,Tags=[{Key=moniker,Value=${PERM_MONIKER}}]" \
                --query "VolumeId") &&
        ssh-keygen -f ${KEY_FILE} -C "temporary ec2 ebs" -P "" &&
        aws \
            ec2 \
            wait \
            instance-running \
            --instance-ids $(aws \
                ec2 \
                run-instances \
                --image-id ami-55ef662f \
                --security-group-ids $(aws ec2 create-security-group --group-name ${SECURITY_GROUP} --description "security group for the ec2 ebs environment in EC2" --query "GroupId") \
                --count 1 \
                --instance-type t2.micro \
                --key-name $(aws ec2 import-key-pair --key-name ${KEY_NAME} --public-key-material "$(cat ${KEY_FILE}.pub)" --query "KeyName") \
                --placement AvailabilityZone=$(aws ec2 describe-volumes --filters Name=tag:moniker,Values=${PERM_MONIKER} --query "Volumes[*].AvailabilityZone") \
                --tag-specifications "ResourceType=instance,Tags=[{Key=moniker,Value=${TEMP_MONIKER}}]" \
                --query "Instances[0].InstanceId") &&
        DEVICE=$(aws \
            ec2 \
            attach-volume \
            --device /dev/sdh \
            --volume-id $(aws ec2 describe-volumes --filters Name=tag:moniker,Values=${PERM_MONIKER} --query "Volumes[*].VolumeId") \
            --instance-id $(aws ec2 describe-instances --filters Name=tag:moniker,Values=${TEMP_MONIKER} Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId") \
            --query "Device") && 
    aws ec2 authorize-security-group-ingress --group-name ${SECURITY_GROUP} --protocol tcp --port 22 --cidr 0.0.0.0/0 &&
    (cat > ${DOT_SSH_CONFIG_FILE} <<EOF
Host ${TEMP_MONIKER}-ec2
HostName $(aws ec2 describe-instances --filter Name=tag:moniker,Values=${TEMP_MONIKER} Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].PublicIpAddress")
User ec2-user
IdentityFile ${KEY_FILE}
EOF
    ) &&
    sleep 15s &&
    ssh-keyscan $(aws ec2 describe-instances --filter Name=tag:moniker,Values=${TEMP_MONIKER} Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].PublicIpAddress") >> ${HOME}/.ssh/known_hosts &&
    ssh ${TEMP_MONIKER}-ec2 sudo mkfs -t ext4 ${DEVICE} &&
    ssh ${TEMP_MONIKER}-ec2 sudo mkdir /data &&
    ssh ${TEMP_MONIKER}-ec2 sudo mount ${DEVICE} /data &&
    rm -f ${DOT_SSH_CONFIG_FILE} ${KEY_FILE} ${KEY_FILE}.pub &&
    aws \
        ec2 \
        wait \
        instance-terminated \
        --instance-ids $(aws \
            ec2 \
            terminate-instances \
            --instance-ids $(aws ec2 describe-instances --filters Name=tag:moniker,Values=${TEMP_MONIKER} Name=instance-state-name,Values=running --query "Reservations[0].Instances[*].InstanceId") \
            --query "TerminatingInstances[*].InstanceId") &&
    aws ec2 delete-security-group --group-name ${SECURITY_GROUP} &&
    aws ec2 delete-key-pair --key-name ${KEY_NAME}
