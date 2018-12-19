# frozen_string_literal: true

require './spec_helper'

init_conf

apache_package = @hiera.lookup('apache::apache_name', nil, @scope)
apache_package ||= 'httpd'

apache_http_port = @hiera.lookup('aem_curator::install_dispatcher::apache_http_port', nil, @scope)
apache_https_port = @hiera.lookup('aem_curator::install_dispatcher::apache_https_port', nil, @scope)

cert_filename = @hiera.lookup('aem_curator::install_dispatcher::cert_filename', nil, @scope)

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

# TODO: check disapatcher installation.
# dispatcher module installation differs depending on os and apache version.
if os[:family] == 'redhat'

end
