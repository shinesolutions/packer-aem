# frozen_string_literal: true

require './spec_helper'

init_conf

component = @scope['::packer_build_name']

describe gem('ruby_aem', '/opt/puppetlabs/puppet/bin/gem') do
  before do
    skip if component.eql? 'java'
    skip if component.eql? 'dispatcher'
    skip if component.eql? 'base'
  end

  it { should be_installed }
  its('version') { should eq '3.8.0' }
end

describe gem('ruby_aem_aws', '/opt/puppetlabs/puppet/bin/gem') do
  before do
    skip if component.eql? 'java'
    skip if component.eql? 'dispatcher'
    skip if component.eql? 'base'
  end

  it { should be_installed }
  its('version') { should eq '1.5.0' }
end
