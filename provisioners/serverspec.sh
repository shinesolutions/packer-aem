#!/bin/bash
component=$1
sudo gem install bundler --no-ri --no-rdoc
cd /tmp/tests
bundle install --path=vendor
bundle exec rake spec SPEC=spec/${component}_spec.rb
