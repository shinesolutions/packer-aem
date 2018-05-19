#!/usr/bin/env bash
set -o nounset
set -o errexit

yum -y upgrade
rpm -ivh --force https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
yum -y install puppet-agent

# when installing puppet5, we got this error as Amazon Linux does not have systemd
# Error: Package: puppet-agent-5.3.3-1.el7.x86_64 (puppet5) Requires: systemd
#sudo rpm -Uvh https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
#yum -y install puppet-agent

exit 0
