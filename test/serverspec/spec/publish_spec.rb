require 'spec_helper'

aem_base = @hiera.lookup('publish::aem_base', nil, @scope)
aem_base ||= '/opt'

aem_port = @hiera.lookup('publish::aem_port', nil, @scope)
aem_port ||= '4503'

describe file("#{aem_base}/aem") do
  it { should be_directory }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file("#{aem_base}/aem/publish") do
  it { should be_directory }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by 'aem-publish' }
  it { should be_grouped_into 'aem-publish' }
end

describe file("#{aem_base}/aem/publish/license.properties") do
  it { should be_file }
  it { should exist }
  it { should be_mode 440 }
  it { should be_owned_by 'aem-publish' }
  it { should be_grouped_into 'aem-publish' }
end

describe file("#{aem_base}/aem/publish/aem-publish-#{aem_port}.jar") do
  it { should be_file }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by 'aem-publish' }
  it { should be_grouped_into 'aem-publish' }
end

# Service will be renamed to 'aem' on next puppet-aem release.
# https://github.com/bstopp/puppet-aem/commit/a28d87fbf6bafc81ff00dec1759d8848708f32af
describe service('aem-publish') do
  it { should_not be_enabled }
# serverspec is using ps aux | grep -w to determine if a service is running
# # aem is just a java process, which fails the test
# it { should be_running }

end

describe file('/etc/puppetlabs/puppet/publish.yaml') do
  it { should be_file }
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end
