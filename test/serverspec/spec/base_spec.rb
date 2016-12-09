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

if os[:family] == 'redhat'

  describe file('/etc/selinux/config') do
    it { should exist }
    it { should be_file }
    it { should contain 'SELINUX=disabled' }
  end

  describe file('/etc/sysconfig/clock') do
    it { should exist }
    it { should be_file }
    it { should contain "ZONE=\"#{region}/#{locality}\"" }
  end

end

# the serverspec module installs the ruby package
describe package('ruby') do
  it { should be_installed }
end
