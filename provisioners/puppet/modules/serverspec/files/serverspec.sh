#!/usr/bin/env bash
set -o nounset
set -o errexit

component=$1
staging_dir=$2
serverspec_dir=/tmp/shinesolutions/packer-aem/serverspec

sudo -E gem install bundler --no-ri --no-rdoc

cd ${serverspec_dir}
bundle install --path=vendor
FACTER_packer_build_name=${component} FACTER_packer_staging_dir=${staging_dir} bundle exec rake spec SPEC="spec/${component}_spec.rb"
