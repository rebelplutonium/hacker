#!/bin/sh


# this works except that you have to answer yes
# to a security question
# so much bullshit
aws \
    ec2 \
    wait \
    instance-running \
    --instance-ids $(aws \
        ec2 \
        run-instances \
        --image-id ami-55ef662f \
        --security-group-ids $(aws ec2 create-security-group --group-name $(uuidgen) --description "security group for the lieutenant environment in EC2" --query "GroupId" --output text) \
        --count 1 \
        --instance-type t2.micro \
        --key-name $(aws ec2 import-key-pair --key-name $(uuidgen) --public-key-material "${LIEUTENANT_AWS_PUBLIC_KEY}" --query "KeyName" --output text) \
        --tag-specifications "ResourceType=instance,Tags=[{Key=moniker,Value=lieutenant}]" \
        --query "Instances[0].InstanceId" \
        --output text) &&
    aws ec2 associate-address --allocation-id $(aws ec2 allocate-address --query "AllocationId" --output text) --instance-id $(aws ec2 describe-instances --filter Name=tag:moniker,Values=lieutenant Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text) &&
    DOT_SSH=$(mktemp -d) &&
    chmod 0700 ${DOT_SSH} &&
    echo "${LIEUTENANT_AWS_PRIVATE_KEY}" > ${DOT_SSH}/id_rsa &&
    (cat > ${DOT_SSH}/config <<EOF
Host lieutenant-ec2
HostName $(aws ec2 describe-instances --filter Name=tag:moniker,Values=lieutenant Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
User ec2-user
IdentityFile ${DOT_SSH}/id_rsa
UserKnownHostsFile ${DOT_SSH}/known_hosts
EOF
    ) &&
    chmod 0600 ${DOT_SSH}/config ${DOT_SSH}/id_rsa &&
    sleep 30s &&
    ssh-keyscan $(aws ec2 describe-instances --filter Name=tag:moniker,Values=lieutenant Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].PublicIpAddress" --output text) > ${DOT_SSH}/known_hosts &&
    cat ${DOT_SSH}/known_hosts &&
    chmod 0644 ${DOT_SSH}/known_hosts &&
    aws \
        ec2 \
        authorize-security-group-ingress \
        --group-id $(aws ec2 describe-instances --filters Name=tag:moniker,Values=lieutenant Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].SecurityGroups[*].GroupId" --output text) \
        --protocol tcp \
        --port 22 \
        --cidr 0.0.0.0/0 &&
    aws \
        ec2 \
        wait \
        volume-available \
        --volume-ids $(aws \
            ec2 \
            create-volume \
            --availability-zone $(aws ec2 describe-instances --filters Name=tag:moniker,Values=lieutenant Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].Placement.AvailabilityZone" --output text) \
            --no-encrypted \
            --size 10 \
            --tag-specifications "ResourceType=volume,Tags=[{Key=moniker,Value=lieutenant}]" \
            --query "VolumeId" \
            --output text) &&
    aws \
        ec2 \
        attach-volume \
        --device /dev/sdh \
        --volume-id $(aws ec2 describe-volumes --filters Name=tag:moniker,Values=lieutenant --query "Volumes[*].VolumeId" --output text) \
        --instance-id $(aws ec2 describe-instances --filters Name=tag:moniker,Values=lieutenant Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text) &&
    ssh -F ${DOT_SSH}/config lieutenant-ec2 sudo mkfs -t ext4 /dev/xvdh &&
    ssh -F ${DOT_SSH}/config lieutenant-ec2 sudo mkdir /data &&
    ssh -F ${DOT_SSH}/config lieutenant-ec2 sudo mount /dev/xvdh /data &&
    echo "find /dev/disk/by-uuid/ -mindepth 1 | while read FILE; do [ \$(readlink -f \${FILE}) == \"/dev/xvdh\" ] && basename \${FILE} ; done | while read UUID; do echo \"UUID=\${UUID}       /data   ext4    defaults,nofail        0       2\" | sudo tee --append /etc/fstab ; done" | ssh -F ${DOT_SSH}/config lieutenant-ec2 sh 
