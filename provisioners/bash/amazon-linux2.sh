#!/usr/bin/env bash
set -o nounset
set -o errexit

yum -y upgrade

rpm -Uvh https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
yum -y install puppet-agent
