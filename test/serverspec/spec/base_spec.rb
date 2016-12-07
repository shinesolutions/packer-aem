require 'spec_helper'

app_dir = @properties['base::app_dir']
aws_user = @properties['base::aws_user']
aws_group = @properties['base::aws_group']

region = @properties['timezone::region']
locality = @properties['timezone::locality']

describe file(app_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by "#{aws_user}" }
  it { should be_grouped_into "#{aws_group}" }
end


# the serverspec module installs the ruby package
describe package('ruby') do
  it { should be_installed }
end

describe command('grep ZONE /etc/sysconfig/clock'), :if => os[:family] == 'redhat' do
  its(:stdout) { should match "ZONE=\"#{region}/#{locality}\"" }
  its(:exit_status) { should eq 0 }
end
