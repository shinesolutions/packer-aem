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
components="java"

for component in $components
do
	CUSTOM_STAGE_RUN_INFO="aem-helloworld-${component}" make "${platform_type}-${component}" "config_path=stage/user-config/${platform_type}-${os_type}-${aem_version}" "version=${test_id}"
done
