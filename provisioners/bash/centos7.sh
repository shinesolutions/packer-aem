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

yum -y upgrade

# install puppet
# Temporary disabling installation of the latest version of puppet-agent due to an issue with configuring AEM using ruby_aem
# More information: https://github.com/shinesolutions/packer-aem/issues/218
#
# rpm -ivh --force "https://yum.puppet.com/puppet${PUPPET_MAJOR_VERSION}/puppet${PUPPET_MAJOR_VERSION}-release-${OS_TYPE}-${OS_VERSION}.noarch.rpm"
# yum -y install puppet-agent epel-release
yum -y install "https://yum.puppetlabs.com/puppet${PUPPET_MAJOR_VERSION}/${OS_TYPE}/${OS_VERSION}/${ARCH_TYPE}/puppet-agent-${PUPPET_AGENT_VERSION}-1.${OS_TYPE}${OS_VERSION}.${ARCH_TYPE}.rpm"
yum -y install epel-release

rpm -ivh --force "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${OS_VERSION}.noarch.rpm"
yum-config-manager --enable rhui-REGION-rhel-server-optional
yum-config-manager --enable rhui-REGION-rhel-server-extras
yum-config-manager --enable "rhel-${OS_VERSION}-server-rhui-optional-rpms"

# AEM and Apache httpd provisioning will create users with certain sudo access
yum install -y sudo

# AEM and Apache httpd provisioning are still using service command
yum install -y initscripts
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ "$i" == systemd-tmpfiles-setup.service ] || rm -f "$i"; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
/usr/sbin/init
