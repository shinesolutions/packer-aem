#!/bin/bash
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install puppet-agent -y
"$PUPPET_BIN_DIR"/puppet resource package puppet ensure=latest

# Enable the rhui-REGION-rhel-server-optional to install ruby-devel
yum-config-manager --enable rhui-REGION-rhel-server-optional
