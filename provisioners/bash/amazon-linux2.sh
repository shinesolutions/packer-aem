#!/usr/bin/env bash
set -o nounset
set -o errexit

# Tomcat 8.x was moved to amazon-linux-extras https://aws.amazon.com/amazon-linux-2/faqs/#Amazon_Linux_Extras
# need to enable the package in order to access it via yum from Puppet manifest
# enabling tomcat8.5 will set Tomcat 8.5 as the default tomcat package installation
amazon-linux-extras enable tomcat8.5

# yum-utils is needed by Amazon Linux 2 Docker image which doesn't include yum-config-manager
yum -y install yum-utils

yum -y upgrade

# install puppet5
rpm -Uvh https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
yum -y install puppet-agent

# Enable the rhui-REGION-rhel-server-optional to install ruby-devel
rpm -ivh --force https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable rhui-REGION-rhel-server-optional

# AEM and Apache httpd provisioning will create users with certain sudo access
yum install -y sudo
