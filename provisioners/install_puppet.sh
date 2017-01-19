#!/bin/bash
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install puppet-agent -y
/opt/puppetlabs/bin/puppet resource package puppet ensure=4.8
yum update -y
