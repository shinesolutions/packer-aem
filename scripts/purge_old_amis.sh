#!/bin/bash -ex

# Purge AEM related AMIs if not referenced by any LaunchConfigurations, Running
# instances
#
# It also deletes the snapshots used by the AMIs if no longer referenced by
# other AMIs.
#
# It can accept a role arn to check if the AMI used in another account, catering
# for sharing AMI from a dev acct to prod acct scenario
#
# It assumes AWS permissons have been properly configured; in addition, default
# AWS credentials should not use environment variables approach


# check if an AMI is unsed by any LaunchConfiguration and Running instances
function check_ami_unused {

  AMI="$1"
  AMI_IN_USE="true"

  LCG_COUNT=$(aws autoscaling describe-launch-configurations \
             --query 'length(LaunchConfigurations[?ImageId==`'"$AMI"'`].LaunchConfigurationName)' \
             --region ap-southeast-2)
  LCG_COUNT="${LCG_COUNT:-0}"
  if [ "$LCG_COUNT" -gt 0 ]; then
    echo "Not deregistering image $AMI because it is still used by some launch configurations"
    return
  fi

  RUNNING_COUNT=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"\
                    "Name=image-id,Values=$AMI" \
                 --query 'length(Reservations[].Instances[].InstanceId)' \
                 --region ap-southeast-2)
  RUNNING_COUNT="${RUNNING_COUNT:-0}"
  if [ "$RUNNING_COUNT" -gt 0 ]; then
    echo "Not deregistering image $AMI becuase it is still used by some running instances"
    return
  fi

  AMI_IN_USE="false"
}

# snapshots that are not referenced by any AMIs.
function delete_orphaned_snapshots {

  set +o errexit

  SNAPSHOT_IDS=$(aws ec2 describe-snapshots --owner-ids self \
         --filters "Name=tag:Application Id,Values=Adobe Experience Manager (AEM)"\
                   "Name=tag-key,Values=Obsoleted" \
        --query 'Snapshots[].SnapshotId' \
         --region ap-southeast-2 --output text)

  # shellcheck disable=2086
  for SNAPSHOT_ID in $SNAPSHOT_IDS; do
    echo "Deleting snapshot $SNAPSHOT_ID"
    aws ec2 delete-snapshot --snapshot-id "$SNAPSHOT_ID" --region ap-southeast-2
  done

 set -o errexit
}


AMI_ROLE_ARR=("soe AMI" "java AMI" "author AMI" "publish AMI" "dispatcher AMI")

# if a role arn is provided, we'll call assuome role and cache the credentials
if [ "$#" -eq 1 ] ; then
  response=$(aws sts assume-role --role-arn "$1"  --role-session-name 'aem62-purging-ami')
  AWS_ACCESS_KEY_ID_CACHED=$(echo "$response" | jq -r  '.Credentials.AccessKeyId')
  AWS_SECRET_ACCESS_KEY_CACHED=$(echo "$response" | jq -r '.Credentials.SecretAccessKey')
  AWS_SESSION_TOKEN_CACHED=$(echo "$response" | jq -r '.Credentials.SessionToken' )
fi


for (( i=0; i < ${#AMI_ROLE_ARR[@]}; i++)); do
  echo "Processing images for application role \"${AMI_ROLE_ARR[$i]}\" .... "

  OLD_AMIS=$(aws ec2 describe-images --owner self \
         --filters "Name=tag:Application Id,Values=Adobe Experience Manager (AEM)"\
                    "Name=tag:Application Role,Values=${AMI_ROLE_ARR[$i]}" \
         --region ap-southeast-2 --query 'sort_by(Images,&CreationDate)[0:-3].ImageId' \
         --output text)

  if [ "${OLD_AMIS}EMPTY" = "EMPTY" ]; then
    echo "No stale images found for role \"${AMI_ROLE_ARR[$i]}\"."
    continue
  fi
  echo "Found staled images for \"${AMI_ROLE_ARR[$i]}\": ${OLD_AMIS}"

  # shellcheck disable=2086
  for OLD_AMI in $OLD_AMIS; do
    echo "Dealing with staled image: $OLD_AMI"

    AMI_IN_USE="true"

    check_ami_unused "$OLD_AMI"
    if [ "$AMI_IN_USE" = "true" ]; then
      continue
    fi
    echo "Staled image $OLD_AMI is not used in the current account"

    if [ "$#" -eq 1 ]; then
      echo "Checking in a second account with provided role arn"
      export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID_CACHED"
      export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY_CACHED"
      export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN_CACHED"

      check_ami_unused "$OLD_AMI"

      unset AWS_ACCESS_KEY_ID
      unset AWS_SECRET_ACCESS_KEY
      unset AWS_SESSION_TOKEN

      if [ "$AMI_IN_USE" = "true" ]; then
        continue
      fi
      echo "Staled image $OLD_AMI is not used in the second account, neither"
    fi

    SNAPSHOT_IDS=$(aws ec2 describe-images --image-ids "$OLD_AMI" --query 'Images[0].BlockDeviceMappings[].Ebs.SnapshotId' \
                   --region ap-southeast-2 --output text)
    echo "Deregistering staled image $OLD_AMI ...."
    aws ec2 deregister-image --image-id "$OLD_AMI" --region ap-southeast-2

    echo "Marking snapshots $SNAPSHOT_IDS for deletion"
    # shellcheck disable=2086
    aws ec2 create-tags --resources $SNAPSHOT_IDS --tags Key=Obsoleted,Value=  --region ap-southeast-2

    # give AWS some time to propogate image deregistration
    sleep 15

    echo "Deleting old snapshots from deregistered images"
    # shellcheck disable=2086
    delete_orphaned_snapshots

    echo "Done"

  done
done
