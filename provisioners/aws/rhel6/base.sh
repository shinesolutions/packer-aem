#!/usr/bin/env bash
set -o nounset
set -o errexit

rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
yum install puppet-agent -y
"$PUPPET_BIN_DIR"/puppet resource package puppet-agent ensure=latest

# Enable the rhui-REGION-rhel-server-optional to install ruby-devel
yum-config-manager --enable rhui-REGION-rhel-server-optional

sleep 30
while pgrep -f yum; do
    sleep 5
done
