require 'spec_helper'

apache_version = @hiera.lookup('apache::apache_version', nil, @scope)
apache_version ||= ''
apache_version = apache_version.tr('.','')

describe package("httpd#{apache_version}") do
  it { should be_installed }
end

describe service('httpd') do
  it { should be_enabled }
  #it { should be_running }
end

describe port(80) do
  it { should be_listening }
end
