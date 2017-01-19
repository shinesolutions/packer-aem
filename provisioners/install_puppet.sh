#!/bin/bash
sudo yum check-update

sudo -E wget http://google.com

sudo -E wget https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

ls

sudo -E rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm


sudo -E yum install puppet-agent -y

sudo -E /opt/puppetlabs/bin/puppet resource package puppet ensure=latest
sudo -E yum update -y
