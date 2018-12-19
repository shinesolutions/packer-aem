# frozen_string_literal: true

require './spec_helper'

init_conf

apache_package = @hiera.lookup('apache::apache_name', nil, @scope)
apache_package ||= 'httpd'

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
