#!/usr/bin/env bash
set -x

echo "Adding the vagrant ssh public key..."

mkdir /home/vagrant/.ssh
#TODO: create your own public and private keys to use. https://github.com/mitchellh/vagrant/tree/master/keys
curl -Lo /home/vagrant/.ssh/authorized_keys https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh


#TODO:  use https://forge.puppet.com/ghoneycutt/ssh instead
