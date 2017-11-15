#!/usr/bin/env bash
set -o nounset
set -o errexit

yum -y upgrade

rpm -ivh https://yum.puppetlabs.com/puppet5/puppet-release-el-7.noarch.rpm
yum -y install puppet-agent epel-release

# Enable the rhui-REGION-rhel-server-optional to install ruby-devel
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable rhui-REGION-rhel-server-optional
