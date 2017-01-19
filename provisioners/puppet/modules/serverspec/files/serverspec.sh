#!/bin/bash
component=$1
staging_directory=$2
sudo -E gem install bundler --no-ri --no-rdoc
cd /tmp/serverspec
bundle install --path=vendor
FACTER_packer_build_name=${component} FACTER_packer_staging_directory=${staging_directory} bundle exec rake spec SPEC=spec/${component}_spec.rb
