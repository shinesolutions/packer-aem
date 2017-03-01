#!/usr/bin/env bash
set -o nounset
set -o errexit

rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y install puppet-agent epel-release

# Enable the rhui-REGION-rhel-server-optional to install ruby-devel
yum-config-manager --enable rhui-REGION-rhel-server-optional
yum-config-manager --enable epel
