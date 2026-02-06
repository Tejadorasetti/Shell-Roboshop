#! bin/bash

SG_ID="sg-0625b3a68a66a1e06" # replace with your security group id
AMI_ID="ami-0220d79f3f480ecf5" # replace with your desired AMI ID

for insatnce in $@

do
   instance_id=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value='$insatnce'}]"\
    --query 'Instances[0].InstanceId' \
    --output text)

    if [ "$insatnce" == "frontend" ]; then
        IP=$(aws ec2 describe-instances \
        --instance-ids "$instance_id" \
        --query "Reservations[0].Instances[0].PublicIpAddress" \
        --output text)

    else
        IP=$(aws ec2 describe-instances \
        --instance-ids "$instance_id" \
        --query "Reservations[0].Instances[0].PrivateIpAddress" \
        --output text)
    fi

    echo ="IP address of $insatnce is $IP"
done
    

