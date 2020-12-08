# frozen_string_literal: true

require './spec_helper'

init_conf

# region = @hiera.lookup('timezone::region', nil, @scope)
# locality = @hiera.lookup('timezone::locality', nil, @scope)

install_aws_cli = @hiera.lookup('config::base::install_aws_cli', nil, @scope)
install_aws_cli ||= 'true'

install_cloudwatchlogs = @hiera.lookup('config::base::install_cloudwatchlogs', nil, @scope)
install_cloudwatchlogs ||= 'true'

cloudwatchlogs_base_path = @hiera.lookup('config::base::awslogs_path', nil, @scope)
cloudwatchlogs_base_path ||= '/var/awslogs'

# install_aws_agents = @hiera.lookup('config::base::install_aws_agents', nil, @scope)
# install_aws_agents ||= 'true'

awslogs_proxy_path = @hiera.lookup('base::awslogs_proxy_path', nil, @scope)

if os[:family] == 'redhat'

  describe file('/etc/selinux/config') do
    it { should exist }
    it { should be_file }
    its('content') { should match(/SELINUX=disabled/m) }
  end

end

# TODO: currently differences between the rhel 7.2 iso and the aws rhel 7.3
# describe file('/etc/localtime') do
#   it { should exist }
#   it { should be_symlink }
#   it { should be_linked_to "/usr/share/zoneinfo/#{region}/#{locality}" }
# end

if install_aws_cli == true

  describe package(@hiera.lookup('base::python_package', 'python', @scope)) do
    it { should be_installed }
  end

  executables = ['/usr/bin/pip', '/usr/bin/aws']

  executables.each do |exe|
    describe file(exe) do
      it { should exist }
      it { should be_executable }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end

end

if install_cloudwatchlogs == true

  # inspec version 1.51.6. doesn't support Amazon Linux 2. It assumes it uses Upstart.
  # inspec version is locked to 1.51.6 to use train version 0.32 because it doesn't have an aws-sdk dependency:
  # https://github.com/inspec/inspec/blob/v1.51.6/inspec.gemspec#L29
  # inspec supports amazon linux 2 from version v2.1.30 (2018-04-05)
  # https://github.com/inspec/inspec/blob/master/CHANGELOG.md#v2130-2018-04-05
  # remove this bespoke handling once upgraded.
  if %w[amazon].include?(os[:name]) && !os[:release].start_with?('20\d\d')

    describe systemd_service(@hiera.lookup('base::awslogs_service_name', nil, @scope)) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  else

    describe service(@hiera.lookup('base::awslogs_service_name', nil, @scope)) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  # On RHEL or CentOS we are removing the AWSLOGS PID file during the baking.
  # This test is to ensure the file does not exists
  if %w[RedHat].include?(os[:name]) || %w[CentOS].include?(os[:name])
    describe file("#{cloudwatchlogs_base_path}/state/awslogs.pid") do
      it { should_not exist }
    end
  end

  describe file('/etc/awslogs/awslogs.conf') do
    it { should exist }
    it { should be_file }
  end

  describe file(awslogs_proxy_path) do
    it { should exist }
    it { should be_file }
  end

  # TODO: check that the region is the region specified by the cloudwatchlogs::region property

end

# if install_aws_agents == true
#
#   describe service('awsagent') do
#     it { should be_enabled }
#     it { should be_running }
#   end
#
# end

packages = []

packages.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end
