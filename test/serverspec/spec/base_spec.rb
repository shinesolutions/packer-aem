require 'spec_helper'

region = @hiera.lookup('timezone::region', nil, @scope)
locality = @hiera.lookup('timezone::locality', nil, @scope)

install_aws_cli = @hiera.lookup('base::install_aws_cli', nil, @scope)
install_aws_cli ||= 'true'

install_cloudwatchlogs = @hiera.lookup('base::install_cloudwatchlogs', nil, @scope)
install_cloudwatchlogs ||= 'true'


if os[:family] == 'redhat'

  describe file('/etc/selinux/config') do
    it { should exist }
    it { should be_file }
    it { should contain 'SELINUX=disabled' }
  end

end

#TODO: currently differences between the rhel 7.2 iso and the aws rhel 7.3
# describe file('/etc/localtime') do
#   it { should exist }
#   it { should be_symlink }
#   it { should be_linked_to "/usr/share/zoneinfo/#{region}/#{locality}" }
# end

if install_aws_cli == 'true'

  describe package('python') do
    it { should be_installed }
  end

  describe file('/usr/bin/pip') do
    it { should exist }
    it { should be_executable }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 755 }
  end

  describe file('/usr/bin/aws') do
    it { should exist }
    it { should be_executable }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 755 }
  end

end

if install_cloudwatchlogs == 'true'

  describe service('awslogs') do
    it { should be_enabled }
    it { should be_running }
  end

end

# the serverspec module installs the ruby package
describe package('ruby') do
  it { should be_installed }
end
