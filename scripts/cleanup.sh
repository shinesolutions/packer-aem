#!/usr/bin/env bash
set -o nounset
set -o errexit

# Remove traces of MAC address and UUID from network configuration
sed -E -i '/^(HWADDR|UUID)/d' /etc/sysconfig/network-scripts/ifcfg-e*

# Add net.ifnames to /etc/default/grub and rebuild grub.cfg
sed -i -e '/GRUB_CMDLINE_LINUX/ s:"$: net.ifnames=0":' /etc/default/grub
/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg

# Disable udev network rules
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

# Lock root account
passwd -d root
passwd -l root

# Clean up yum
rpm --rebuilddb
yum clean all

# Remove ssh host keys
rm -rf /etc/ssh/ssh_host*_key*

# Clean up /root
rm -f /root/anaconda-ks.cfg
rm -f /root/install.log
rm -f /root/install.log.syslog
rm -rf /root/.pki

# Clean up /var/log
true > /var/log/cron
true > /var/log/dmesg
true > /var/log/lastlog
true > /var/log/maillog
true > /var/log/messages
true > /var/log/secure
true > /var/log/wtmp
true > /var/log/audit/audit.log
true > /var/log/rhsm/rhsm.log
true > /var/log/rhsm/rhsmcertd.log
rm -f /var/log/*.old
rm -f /var/log/*.log
rm -f /var/log/*.syslog

# Clean /tmp
rm -rf /tmp/*
rm -rf /tmp/*.*

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Clear history
history -c

#TODO: add to existing cleanup file.
