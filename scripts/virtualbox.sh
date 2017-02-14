#!/usr/bin/env bash
set -o nounset
set -o errexit

VBOX_ISO=/home/vagrant/VBoxGuestAdditions.iso
VBOX_MNTDIR=$(mktemp --tmpdir=/tmp/shinesolutions/packer-aem -q -d -t vbox_mnt_XXXXXX)

# Install tools
mount -o loop "$VBOX_ISO" "$VBOX_MNTDIR"
yes|sh "$VBOX_MNTDIR/VBoxLinuxAdditions.run"

# Clean up
umount "$VBOX_MNTDIR"
rm -rf "$VBOX_MNTDIR"
rm -f "$VBOX_ISO"

#TODO: use https://docs.puppet.com/puppet/latest/types/mount.html and https://docs.puppet.com/puppet/4.8/types/exec.html
