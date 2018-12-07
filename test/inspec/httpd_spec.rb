# frozen_string_literal: true

require './spec_helper'

init_conf

apache_package = @hiera.lookup('apache::apache_name', nil, @scope)
apache_package ||= 'httpd'

describe package(apache_package) do
  it { should be_installed }
end

describe service('httpd') do
  it { should be_enabled }
  # it { should be_running }
end
