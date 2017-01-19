#!/bin/bash

which puppet
puppet --version

rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install puppet-agent -y
/opt/puppetlabs/bin/puppet resource package puppet ensure=latest
yum update -y

which puppet
puppet --version
