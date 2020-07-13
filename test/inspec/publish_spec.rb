# frozen_string_literal: true

require './spec_helper'

init_conf

aem_base = @hiera.lookup('publish::aem_base', nil, @scope)
aem_base ||= '/opt'

aem_port = @hiera.lookup('publish::aem_port', nil, @scope)
aem_port ||= '4503'

data_volume_mount_point = @hiera.lookup('aem_curator::install_publish::data_volume_mount_point', nil, @scope)
data_volume_mount_point ||= '/mnt/ebs1'

aem_publish_ssl_method = @hiera.lookup('aem_curator::install_publish::aem_ssl_method', nil, @scope)
aem_publish_ssl_method ||= 'jetty'

### SSM paramter store lookup is only supported for hiera5
# aem_keystore_password = @hiera.lookup('aem_curator::install_publish::aem_keystore_password', nil, @scope)

describe file("#{aem_base}/aem") do
  it { should be_directory }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

only_if { aem_publish_ssl_method != 'jetty' }
describe file("#{aem_base}/aem/publish") do
  it { should be_directory }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'aem-publish' }
  it { should be_grouped_into 'aem-publish' }
end

describe file("#{aem_base}/aem/publish/license.properties") do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00440' }
  it { should be_owned_by 'aem-publish' }
  it { should be_grouped_into 'aem-publish' }
end

describe file("#{aem_base}/aem/publish/aem-publish-#{aem_port}.jar") do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'aem-publish' }
  it { should be_grouped_into 'aem-publish' }
end

# describe file("#{aem_base}/aem/publish/crx-quickstart/ssl/aem.ks") do
#   it { should be_file }
#   it { should exist }
#   its('mode') { should cmp '00640' }
#   it { should be_owned_by 'aem-publish' }
#   it { should be_grouped_into 'aem-publish' }
# end

describe service('aem-publish') do
  it { should_not be_enabled }
  it { should_not be_running }
end

# describe aem_keystore_password do
#   it { should_not match(/changeit/) }
# end

# Test if default keystore password is not changeit
describe command("keytool -list -keystore #{data_volume_mount_point}/publish/crx-quickstart/ssl/aem.ks -alias cqse -storepass changeit") do
  its('exit_status') { should_not eq 0 }
end

if File.file?('/lib/systemd/system/aem-publish.service')

  describe file("#{aem_base}/aem/publish/crx-quickstart/conf/cq.pid") do
    it { should_not exist }
  end

end

describe file('/etc/puppetlabs/puppet/publish.yaml') do
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
# describe Dir.empty?("#{aem_base}/aem/publish/crx-quickstart/install") do
#   it { should be true }
# end
