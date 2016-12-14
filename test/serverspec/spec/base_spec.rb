require 'spec_helper'

region = @hiera.lookup('timezone::region', nil, @scope)
locality = @hiera.lookup('timezone::locality', nil, @scope)

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

# the serverspec module installs the ruby package
describe package('ruby') do
  it { should be_installed }
end
