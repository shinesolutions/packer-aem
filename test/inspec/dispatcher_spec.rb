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

describe service('httpd') do
  it { should be_enabled }
  # it { should be_running }
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
  its('size') { should be.positive? }
end

# TODO: check disapatcher installation.
# dispatcher module installation differs depending on os and apache version.
if os[:family] == 'redhat'

end
