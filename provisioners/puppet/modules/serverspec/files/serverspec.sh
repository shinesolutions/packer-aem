#!/bin/bash
component=$1
sudo gem install bundler --no-ri --no-rdoc
cd /tmp/serverspec
bundle install --path=vendor
FACTER_packer_build_name=${component} bundle exec rake spec SPEC=spec/${component}_spec.rb
