#!/bin/sh

WORKSPACE=$(generate-workspace) &&
    DOT_SSH_CONFIG_FILE=$(mktemp ${HOME}/.ssh/config.d/XXXXXXXX) &&
    SECURITY_GROUP=$(uuidgen) &&
    KEY_NAME=$(uuidgen) &&
    KEY_FILE=$(mktemp ${HOME}/.ssh/XXXXXXXX.id_rsa) &&
    rm -f ${KEY_FILE} &&
    cleanup(){
        rm -f ${DOT_SSH_CONFIG_FILE} ${KEY_FILE} ${KEY_FILE}.pub &&
            aws \
                ec2 \
                wait \
                instance-terminated \
                --instance-ids $(aws \
                    ec2 \
                    terminate-instances \
                    --instance-ids $(aws ec2 describe-instances --filters Name=tag:moniker,Values=gitlab Name=instance-state-name,Values=running --query "Reservations[0].Instances[*].InstanceId" --output text) \
                    --query "TerminatingInstances[*].InstanceId" \
                    --output text) &&
            aws ec2 delete-security-group --group-name ${SECURITY_GROUP} &&
            aws ec2 delete-key-pair --key-name ${KEY_NAME} &&
            rm -rf ${WORKSPACE}
    } &&
    trap cleanup EXIT &&
    ssh-keygen -f ${KEY_FILE} -C "temporary gitlab-ec2" -P "" &&
    aws \
        ec2 \
        wait \
        instance-running \
        --instance-ids $(aws \
            ec2 \
            run-instances \
            --image-id ami-55ef662f \
            --security-group-ids $(aws ec2 create-security-group --group-name ${SECURITY_GROUP} --description "security group for the gitlab environment in EC2" --query "GroupId" --output text) \
            --count 1 \
            --instance-type t2.medium \
            --key-name $(aws ec2 import-key-pair --key-name ${KEY_NAME} --public-key-material "$(cat ${KEY_FILE}.pub)" --query "KeyName" --output text) \
            --placement AvailabilityZone=$(aws ec2 describe-volumes --filters Name=tag:moniker,Values=gitlab --query "Volumes[*].AvailabilityZone" --output text) \
            --tag-specifications "ResourceType=instance,Tags=[{Key=moniker,Value=gitlab}]" \
            --query "Instances[0].InstanceId" \
            --output text) &&
    sleep 15s &&
    DEVICE=$(aws \
        ec2 \
        attach-volume \
        --device /dev/sdh \
        --volume-id $(aws ec2 describe-volumes --filters Name=tag:moniker,Values=gitlab --query "Volumes[*].VolumeId" --output text) \
        --instance-id $(aws ec2 describe-instances --filters Name=tag:moniker,Values=gitlab Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text) \
        --query "Device" \
        --output text) &&
    aws ec2 authorize-security-group-ingress --group-name ${SECURITY_GROUP} --protocol tcp --port 22 --cidr 0.0.0.0/0 &&
    (cat > ${DOT_SSH_CONFIG_FILE} <<EOF
Host gitlab-ec2
HostName $(aws ec2 describe-instances --filter Name=tag:moniker,Values=gitlab Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
User ec2-user
IdentityFile ${KEY_FILE}
LocalForward 0.0.0.0:10727 127.0.0.1:12073
LocalForward 0.0.0.0:19129 127.0.0.1:14465
LocalForward 0.0.0.0:18712 127.0.0.1:16955
ControlMaster auto
ControlPath ~/.ssh/ec2-user.%h-%p-%r.ctrl_path
EOF
    ) &&
    sleep 15s &&
    ssh-keyscan $(aws ec2 describe-instances --filter Name=tag:moniker,Values=gitlab Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].PublicIpAddress" --output text) >> ${HOME}/.ssh/known_hosts &&
    ssh gitlab-ec2 sudo mkdir /srv/gitlab &&
    ssh gitlab-ec2 sudo mount ${DEVICE} /srv/gitlab &&
    echo "find /dev/disk/by-uuid/ -mindepth 1 | while read FILE; do [ \$(readlink -f \${FILE}) == \"${DEVICE}\" ] && basename \${FILE} ; done | while read UUID; do echo \"UUID=\${UUID}       /srv/data   ext4    defaults,nofail        0       2\" | sudo tee --append /etc/fstab ; done" | ssh gitlab-ec2 sh &&
    ssh gitlab-ec2 sudo yum update --assumeyes &&
    ssh gitlab-ec2 sudo yum install --assumeyes docker &&
    ssh gitlab-ec2 sudo service docker start &&
    ssh \
        gitlab-ec2 \
        sudo \
        docker \
        container \
        create \
        --name gitlab \
        --detach \
        --publish 127.0.0.1:12073:443 \
        --publish 127.0.0.1:14465:80 \
        --publish 127.0.0.1:16955:22 \
        --restart always \
        --volume /srv/gitlab/config:/etc/gitlab \
        --volume /srv/gitlab/logs:/var/log/gitlab \
        --volume /srv/gitlab/data:/var/opt/gitlab \
        gitlab/gitlab-ce:10.4.0-ce.0 &&
    ssh \
        gitlab-ec2 \
        sudo \
        docker \
        container \
        create \
        --detach \
        --name docker \
        --privileged \
        docker:17.12.0-dind &&
    ssh \
        gitlab-ec2 \
        sudo \
        docker \
        create \
        --detach \
        --name gitlab-runner \
        --restart always \
        --volume /srv/gitlab/runner:/etc/gitlab-runner \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        gitlab/gitlab-runner:latest &&
    ssh gitlab-ec2 sudo network create main &&
    ssh gitlab-ec2 sudo network connect --alias gitlab main gitlab &&
    ssh gitlab-ec2 sudo network connect --alias docker main docker &&
    ssh gitlab-ec2 sudo network connect main gitlab-runner &&
    ssh gitlab-ec2 &&
    bash