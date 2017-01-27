#!/bin/bash
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install puppet-agent -y
"$PUPPET_BIN_DIR"/puppet resource package puppet ensure=latest

# TODO: install the epel repo for installation of gcc, ruby-devel and zlib-devel
## RHEL/CentOS 7 64-Bit ##
# wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
# rpm -ivh epel-release-7-8.noarch.rpm
