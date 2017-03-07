#!/bin/bash -x


sudo yum -y install jq

AMI_ROLE_ARR=("Base AMI" "Java AMI" "AEM Author AMI" "AEM Publish AMI" "Apache HTTP Server AMI" "AEM Dispatcher AMI")

for (( i=0; i < ${#AMI_ROLE_ARR[@]}; i++)); do
  echo "${AMI_ROLE_ARR[$i]}"

  OLD_AMIS=$(aws ec2 describe-images --owner self \
         --filters "Name=tag:Application Id,Values=Adobe Experience Manager (AEM)"\
                    "Name=tag:Application Role,Values=${AMI_ROLE_ARR[$i]}" \
         --region ap-southeast-2 | jq -r '."Images"|sort_by(."CreationDate")|.[0:-3]|.[]."ImageId"')

  for OLD_AMI in $OLD_AMIS; do
    aws ec2 deregister-image --image-id "$OLD_AMI" --region ap-southeast-2
    sleep 1
  done
done

