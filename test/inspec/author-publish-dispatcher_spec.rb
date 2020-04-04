# frozen_string_literal: true

require './spec_helper'

init_conf

aem_base = @hiera.lookup('author::aem_base', nil, @scope)
aem_base ||= '/opt'

aem_port = @hiera.lookup('author::aem_port', nil, @scope)
aem_port ||= '4502'

author_data_volume_mount_point = @hiera.lookup('aem_curator::install_author::data_volume_mount_point', nil, @scope)
author_data_volume_mount_point ||= '/mnt/ebs1'

### SSM paramter store lookup is only supported for hiera5
# aem_author_keystore_password = @hiera.lookup('aem_curator::install_author::aem_keystore_password', nil, @scope)

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

describe service('aem-author') do
  it { should_not be_enabled }
  it { should_not be_running }
end

# describe aem_author_keystore_password do
#   it { should_not match(/changeit/) }
# end

# Test if default keystore password is not changeit
describe command("keytool -list -keystore #{author_data_volume_mount_point}/author/crx-quickstart/ssl/aem.ks -alias cqse -storepass changeit") do
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

aem_base = @hiera.lookup('publish::aem_base', nil, @scope)
aem_base ||= '/opt'

aem_port = @hiera.lookup('publish::aem_port', nil, @scope)
aem_port ||= '4503'

publish_data_volume_mount_point = @hiera.lookup('aem_curator::install_publish::data_volume_mount_point', nil, @scope)
publish_data_volume_mount_point ||= '/mnt/ebs2'

### SSM paramter store lookup is only supported for hiera5
# aem_publish_keystore_password = @hiera.lookup('aem_curator::install_publish::aem_keystore_password', nil, @scope)

describe file("#{aem_base}/aem") do
  it { should be_directory }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

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

describe service('aem-publish') do
  it { should_not be_enabled }
  it { should_not be_running }
end

# describe aem_publish_keystore_password do
#   it { should_not match(/changeit/) }
# end

# Test if default keystore password is changeit
describe command("keytool -list -keystore #{publish_data_volume_mount_point}/publish/crx-quickstart/ssl/aem.ks -alias cqse -storepass changeit") do
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

apache_package = @hiera.lookup('apache::apache_name', nil, @scope)
apache_package ||= 'httpd'

apache_http_port = @hiera.lookup('aem_curator::install_dispatcher::apache_http_port', nil, @scope)
apache_https_port = @hiera.lookup('aem_curator::install_dispatcher::apache_https_port', nil, @scope)

cert_filename = @hiera.lookup('aem_curator::install_dispatcher::cert_filename', nil, @scope)

dispatcher_id = @hiera.lookup('aem_curator::install_dispatcher::aem_id', 'dispatcher', @scope)

setup_data_volume = @hiera.lookup('aem_curator::install_dispatcher::setup_data_volume', nil, @scope)

# data_volume_device = @hiera.lookup('aem_curator::install_dispatcher::data_volume_device', nil, @scope)
data_volume_device = '/dev/xvdd'

# data_volume_mount_point = @hiera.lookup('aem_curator::install_dispatcher::data_volume_mount_point', nil, @scope)
data_volume_mount_point = '/mnt/ebs3'

docroot_dir = @hiera.lookup('aem_curator::install_dispatcher::docroot_dir', '/var/www/html', @scope)

apache_user = @hiera.lookup('aem_curator::install_dispatcher::apache_user', 'apache', @scope)

apache_group = @hiera.lookup('aem_curator::install_dispatcher::apache_group', 'apache', @scope)

if setup_data_volume
  describe mount(data_volume_mount_point) do
    it { should be_mounted }
    its('device') { should eq data_volume_device }
  end

  describe file(docroot_dir) do
    it { should exist }
    it { should be_symlink }
    its('link_path') { should eq "#{data_volume_mount_point}/#{dispatcher_id}" }
  end
else
  describe file(docroot_dir) do
    it { should exist }
    it { should be_directory }
    its('owner') { should eq apache_user }
    its('group') { should eq apache_group }
  end
end

describe package(apache_package) do
  it { should be_installed }
end

# inspec version 1.51.6. doesn't support Amazon Linux 2. It assumes it uses Upstart.
# inspec version is locked to 1.51.6 to use train version 0.32 because it doesn't have an aws-sdk dependency:
# https://github.com/inspec/inspec/blob/v1.51.6/inspec.gemspec#L29
# inspec supports amazon linux 2 from version v2.1.30 (2018-04-05)
# https://github.com/inspec/inspec/blob/master/CHANGELOG.md#v2130-2018-04-05
# remove this bespoke handling once upgraded.
if %w[amazon].include?(os[:name]) && !os[:release].start_with?('20\d\d')

  describe systemd_service(apache_package) do
    it { should be_enabled }
    it { should be_running }
  end

else

  describe service(apache_package) do
    it { should be_enabled }
    it { should be_running }
  end

end

describe port(apache_http_port) do
  it { should be_listening }
end

describe port(apache_https_port) do
  it { should be_listening }
end

describe file(cert_filename) do
  it { should be_file }
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should cmp '00600' }
  its('size') { should be > 0 }
end
