require './spec_helper'

init_conf

region = @hiera.lookup('timezone::region', nil, @scope)
locality = @hiera.lookup('timezone::locality', nil, @scope)

install_aws_cli = @hiera.lookup('config::base::install_aws_cli', nil, @scope)
install_aws_cli ||= 'true'

install_cloudwatchlogs = @hiera.lookup('config::base::install_cloudwatchlogs', nil, @scope)
install_cloudwatchlogs ||= 'true'

install_aws_agents = @hiera.lookup('config::base::install_aws_agents', nil, @scope)
install_aws_agents ||= 'true'


if os[:family] == 'redhat'

  describe file('/etc/selinux/config') do
    it { should exist }
    it { should be_file }
    its('content') { should match /SELINUX=disabled/m }
  end

end

#TODO: currently differences between the rhel 7.2 iso and the aws rhel 7.3
# describe file('/etc/localtime') do
#   it { should exist }
#   it { should be_symlink }
#   it { should be_linked_to "/usr/share/zoneinfo/#{region}/#{locality}" }
# end

if install_aws_cli == true

  describe package(@hiera.lookup('base::python_package', 'python', @scope)) do
    it { should be_installed }
  end

  executables = [ '/usr/bin/pip', '/usr/bin/aws' ]

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

  describe service(@hiera.lookup('base::awslogs_service', 'awslogs', @scope)) do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/awslogs/awslogs.conf') do
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

packages = [
  'gcc',
  'ruby-devel',
  'zlib-devel',
  'ruby',
  @hiera.lookup('base::python_cheetah_package', 'python-cheetah', @scope),
]

packages.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end
