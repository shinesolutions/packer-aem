#!/usr/bin/env bash
set -o nounset
set -o errexit

# Disable cloud-init log forwarding to syslog in order to prevent 'serial8250: too much work for irq4'
sed -i 's/ - \[ \*log_base, \*log_file \]/# - \[ \*log_base, \*log_file \]/g' /etc/cloud/cloud.cfg.d/05_logging.cfg

# yum-utils is needed by Amazon Linux 2 Docker image which doesn't include yum-config-manager
yum -y install yum-utils

yum -y upgrade

# install puppet5
rpm -Uvh https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
yum -y install puppet-agent

# Enable the rhui-REGION-rhel-server-optional to install ruby-devel
rpm -ivh --force https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable rhui-REGION-rhel-server-optional

# Install development tools needed to natively build Nokogiri (a dependency of ruby_aem)
# TODO: reduce the footprint and only install the ones required by Nokogiri
yum -y groupinstall 'Development Tools'

# AEM and Apache httpd provisioning will create users with certain sudo access
yum install -y sudo
