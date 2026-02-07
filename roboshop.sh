#! bin/bash

SG_ID="sg-0625b3a68a66a1e06" # replace with your security group id
AMI_ID="ami-0220d79f3f480ecf5" # replace with your desired AMI ID
Zone_ID="Z0040584OWLEELXMLC9V" # replace with your hosted zone ID
Domain_name="learn-devops.cloud" # replace with your domain name

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
    Record_name="$Domain_name"

    else
        IP=$(aws ec2 describe-instances \
        --instance-ids "$instance_id" \
        --query "Reservations[0].Instances[0].PrivateIpAddress" \
        --output text)

     Record_name="$insatnce.$Domain_name"
    fi

    echo "IP address of $insatnce is $IP"
    aws route53 change-resource-record-sets \
    --hosted-zone-id $Zone_ID \
    --change-batch '{"Changes": [{"Action": "UPSERT", "ResourceRecordSet": {"Name": "'$Record_name'", "Type": "A", "TTL": 1, "ResourceRecords": [{"Value": "'$IP'"}]}}]}'

    echo "record updated for $insatnce with IP $IP"
done
    

