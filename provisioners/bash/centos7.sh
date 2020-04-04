#!/usr/bin/env bash
set -o nounset
set -o errexit

yum -y upgrade

rpm -ivh --force https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
yum -y install puppet-agent epel-release

rpm -ivh --force https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable rhui-REGION-rhel-server-optional
yum-config-manager --enable rhui-REGION-rhel-server-extras
yum-config-manager --enable rhel-7-server-rhui-optional-rpms

# AEM and Apache httpd provisioning will create users with certain sudo access
yum install -y sudo

# AEM and Apache httpd provisioning are still using service command
yum install -y initscripts
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ "$i" == systemd-tmpfiles-setup.service ] || rm -f "$i"; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
/usr/sbin/init
