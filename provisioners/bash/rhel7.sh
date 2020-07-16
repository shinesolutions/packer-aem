#!/usr/bin/env bash
set -o nounset
set -o errexit

PUPPET_MAJOR_VERSION=5
PUPPET_MINOR_VERSION=5
PUPPET_PATCH_VERSION=20
PUPPET_AGENT_VERSION="${PUPPET_MAJOR_VERSION}.${PUPPET_MINOR_VERSION}.${PUPPET_PATCH_VERSION}"
ARCH_TYPE=x86_64
OS_TYPE=el
OS_VERSION=7

# Temporarily exclude python-urllib3 from upgrade due to error with unpacking rpm package python-urllib3-1.10.2-7.el7.noarch
# `aws: error: unpacking of archive failed on file /usr/lib/python2.7/site-packages/urllib3/packages/ssl_match_hostname: cpio: rename`
# TODO: re-include python-urllib3
yum -y upgrade --exclude=python-urllib3-*

# install puppet
# Temporary disabling installation of the latest version of puppet-agent due to an issue with configuring AEM using ruby_aem
# More information: https://github.com/shinesolutions/packer-aem/issues/218
#
# rpm -ivh --force https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
# yum -y install puppet-agent epel-release
yum -y install "https://yum.puppetlabs.com/puppet${PUPPET_MAJOR_VERSION}/${OS_TYPE}/${OS_VERSION}/${ARCH_TYPE}/puppet-agent-${PUPPET_AGENT_VERSION}-1.${OS_TYPE}${OS_VERSION}.${ARCH_TYPE}.rpm"
yum -y install epel-release

rpm -ivh --force "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${OS_VERSION}.noarch.rpm"
yum-config-manager --enable rhui-REGION-rhel-server-optional
yum-config-manager --enable rhui-REGION-rhel-server-extras
yum-config-manager --enable "rhel-${OS_VERSION}-server-rhui-optional-rpms"
