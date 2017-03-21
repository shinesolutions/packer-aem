#!/usr/bin/env bash
set -o nounset
set -o errexit

yum -y upgrade

rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install puppet-agent -y
"$PUPPET_BIN_DIR"/puppet resource package puppet ensure=latest

# Require the EPEL for python-pip package
# https://aws.amazon.com/premiumsupport/knowledge-center/ec2-enable-epel/
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Enable the rhui-REGION-rhel-server-optional to install ruby-devel
yum-config-manager --enable rhui-REGION-rhel-server-optional
