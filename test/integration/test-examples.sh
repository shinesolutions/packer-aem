#!/usr/bin/env bash
set -o errexit

if [[ "$#" -lt 1 ]] || [[ "$#" -gt 4 ]]; then
  echo "Usage: ${0} <test_id> [platform_type] [os_type] [aem_version]"
  exit 1
fi

test_id=$1
platform_type=${2:-aws}
os_type=${3:-rhel7}
aem_version=${4:-aem64}
components="author-publish-dispatcher author publish dispatcher java"
integration_test_config_file=stage/user-config/aws-resources-sandpit/zzz-test.yaml

# Create integration test configuration
echo "Creating integration test configuration file..."
rm -f "${integration_test_config_file}"
echo -e "aws:\n  resources:\n    s3_bucket: ${test_id}-res" > "${integration_test_config_file}"

# Create AWS resources
echo "Creating AWS resources..."
make create-aws-resources "stack_prefix=${test_id}-res" config_path=stage/user-config/aws-resources-sandpit/

# Delete AWS resources
echo "Deleting AWS resources..."
make delete-aws-resources "stack_prefix=${test_id}-res" config_path=stage/user-config/aws-resources-sandpit/

# Create AMIs
for component in $components
do
	CUSTOM_STAGE_RUN_INFO="aem-helloworld-${component}" make "${platform_type}-${component}" "config_path=stage/user-config/${platform_type}-${os_type}-${aem_version}" "version=${test_id}"
done
