# frozen_string_literal: true

require './spec_helper'

init_conf

aem_base = @hiera.lookup('author::aem_base', nil, @scope)
aem_base ||= '/opt'

aem_port = @hiera.lookup('author::aem_port', nil, @scope)
aem_port ||= '4502'

data_volume_mount_point = @hiera.lookup('aem_curator::install_author::data_volume_mount_point', nil, @scope)
data_volume_mount_point ||= '/mnt/ebs1'

aem_keystore_path = @hiera.lookup('aem_curator::install_author::aem_keystore_path', nil, @scope)
aem_keystore_path ||= '/etc/ssl/aem-author/author.ks'

### SSM paramter store lookup is only supported for hiera5
# aem_keystore_password = @hiera.lookup('aem_curator::install_author::aem_keystore_password', nil, @scope)

describe file("#{aem_base}/aem") do
  it { should be_directory }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file("#{aem_base}/aem/author") do
  it { should be_directory }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'aem-author' }
  it { should be_grouped_into 'aem-author' }
end

describe file("#{aem_base}/aem/author/license.properties") do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00440' }
  it { should be_owned_by 'aem-author' }
  it { should be_grouped_into 'aem-author' }
end

describe file("#{aem_base}/aem/author/aem-author-#{aem_port}.jar") do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'aem-author' }
  it { should be_grouped_into 'aem-author' }
end

describe file("#{aem_keystore_path}") do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00640' }
  it { should be_owned_by 'aem-author' }
  it { should be_grouped_into 'aem-author' }
end

describe service('aem-author') do
  it { should_not be_enabled }
  it { should_not be_running }
end

# describe aem_keystore_password do
#   it { should_not match(/changeit/) }
# end

# Test if default keystore password is not changeit
describe command("keytool -list -keystore #{aem_keystore_path} -alias cqse -storepass changeit") do
  its('exit_status') { should_not eq 0 }
end

if File.file?('/lib/systemd/system/aem-author.service')

  describe file("#{aem_base}/aem/author/crx-quickstart/conf/cq.pid") do
    it { should_not exist }
  end

end

describe file('/etc/puppetlabs/puppet/author.yaml') do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00644' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

# TODO: due to the aem-healthcheck life cycle change in AEM OpenCloud 4.0.0, we need to modify the check
#       below to ensure that install directory only contains one file and that file should be aem-healthcheck-content-version.zip
# # Ensure that AEM install directory is empty at the end of provisioning
# # in order to avoid AEM from reinstalling the same package during environment
# # stand up. This scenario is a potential risk of unexpected repository size
# # growth, e.g. a bug in AEM 6.2 where a large AEM package would get reinstalled
# # and added to the repo, but not compacted for a period of time.
# describe Dir.empty?("#{aem_base}/aem/author/crx-quickstart/install") do
#   it { should be true }
# end
