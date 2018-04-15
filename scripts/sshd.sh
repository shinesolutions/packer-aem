#!/usr/bin/env bash
set -o nounset
set -o errexit

echo "Modifying /etc/ssh/sshd_config..."
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config

#TODO: use https://forge.puppet.com/ghoneycutt/ssh instead
