#!/bin/bash
sudo yum check-update

wget http://google.com

wget https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

ls

sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm


sudo yum install puppet-agent -y

sudo /opt/puppetlabs/bin/puppet resource package puppet ensure=latest
sudo yum update -y
