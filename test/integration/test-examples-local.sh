#!/usr/bin/env bash
set -o errexit

# This script is used for integration testing AEM environments using local
# repos, which allows the user to decide whether to use master or a feature
# branch that's being worked on for each of the repos.
# The repositories must be located at the same directory level.
# The AEM environments are created using examples user configurations.

if [[ "$#" -lt 1 ]] || [[ "$#" -gt 4 ]]; then
  echo "Usage: ${0} <test_id> [platform_type] [os_type] [aem_version]"
  exit 1
fi

test_id=$1
platform_type=${2:-aws}
aem_version=${3:-aem64}
os_type=${4:-rhel7}

for component in author-publish-dispatcher author publish dispatcher java
do
	make "${platform_type}-${component}" "config_path=stage/user-config/${platform_type}-${os_type}-${aem_version}" "version=${test_id}"
done
