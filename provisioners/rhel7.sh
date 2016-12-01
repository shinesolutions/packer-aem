#!/bin/bash
sleep 30
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum install puppet -y
sudo puppet resource package puppet ensure=latest
#sudo yum update -y
