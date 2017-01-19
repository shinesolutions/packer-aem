#!/bin/bash

echo "http_proxy=$http_proxy"
ping forwardproxy

sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum install puppet-agent -y
sudo /opt/puppetlabs/bin/puppet resource package puppet ensure=latest
sudo yum update -y
