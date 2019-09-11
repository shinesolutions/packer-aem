#!/usr/bin/env bash
set -o nounset
set -o errexit

# Temporarily exclude python-urllib3 from upgrade due to error with unpacking rpm package python-urllib3-1.10.2-7.el7.noarch
# `aws: error: unpacking of archive failed on file /usr/lib/python2.7/site-packages/urllib3/packages/ssl_match_hostname: cpio: rename`
# TODO: re-include python-urllib3
yum -y upgrade --exclude=python-urllib3-*

rpm -ivh --force https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
yum -y install puppet-agent epel-release

# Enable the rhui-REGION-rhel-server-optional to install ruby-devel
rpm -ivh --force https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable rhui-REGION-rhel-server-optional

# Install Iptables and enable it
yum install -y iptables-services
systemctl start iptables
systemctl enable iptables
