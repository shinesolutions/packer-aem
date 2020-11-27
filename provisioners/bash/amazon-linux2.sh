#!/usr/bin/env bash
set -o nounset
set -o errexit

PUPPET_MAJOR_VERSION=5
PUPPET_MINOR_VERSION=5
PUPPET_PATCH_VERSION=22
PUPPET_AGENT_VERSION="${PUPPET_MAJOR_VERSION}.${PUPPET_MINOR_VERSION}.${PUPPET_PATCH_VERSION}"
ARCH_TYPE=x86_64
OS_TYPE=el
OS_VERSION=7

# Tomcat 8.x was moved to amazon-linux-extras https://aws.amazon.com/amazon-linux-2/faqs/#Amazon_Linux_Extras
# need to enable the package in order to access it via yum from Puppet manifest
# enabling tomcat8.5 will set Tomcat 8.5 as the default tomcat package installation
amazon-linux-extras enable tomcat8.5

# yum-utils is needed by Amazon Linux 2 Docker image which doesn't include yum-config-manager
yum -y install yum-utils

yum -y upgrade

# install puppet
# Temporary disabling installation of the latest version of puppet-agent due to an issue with configuring AEM using ruby_aem
# More information: https://github.com/shinesolutions/packer-aem/issues/218
#
# rpm -Uvh "https://yum.puppet.com/puppet${PUPPET_MAJOR_VERSION}/puppet${PUPPET_MAJOR_VERSION}-release-${OS_TYPE}-${OS_VERSION}.noarch.rpm"
# yum -y install puppet-agent
yum -y install "https://yum.puppetlabs.com/puppet${PUPPET_MAJOR_VERSION}/${OS_TYPE}/${OS_VERSION}/${ARCH_TYPE}/puppet-agent-${PUPPET_AGENT_VERSION}-1.${OS_TYPE}${OS_VERSION}.${ARCH_TYPE}.rpm"

rpm -ivh --force "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${OS_VERSION}.noarch.rpm"
yum-config-manager --enable rhui-REGION-rhel-server-optional
yum-config-manager --enable rhui-REGION-rhel-server-extras
yum-config-manager --enable "rhel-${OS_VERSION}-server-rhui-optional-rpms"

# AEM and Apache httpd provisioning will create users with certain sudo access
yum install -y sudo
