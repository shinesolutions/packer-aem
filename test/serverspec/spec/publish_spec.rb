require 'spec_helper'

aem_base = @hiera.lookup('publish::aem_base', nil, @scope)
aem_base ||= '/opt'

aem_port = @hiera.lookup('publish::aem_port', nil, @scope)
aem_port ||= '4503'

describe file("#{aem_base}/aem") do
  it { should be_directory }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by 'aem' }
  it { should be_grouped_into 'aem' }
end

describe file("#{aem_base}/aem/publish") do
  it { should be_directory }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by 'aem' }
  it { should be_grouped_into 'aem' }
end

describe file("#{aem_base}/aem/publish/license.properties") do
  it { should be_file }
  it { should exist }
  it { should be_mode 440 }
  it { should be_owned_by 'aem' }
  it { should be_grouped_into 'aem' }
end

describe file("#{aem_base}/aem/publish/aem-publish-#{aem_port}.jar") do
  it { should be_file }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by 'aem' }
  it { should be_grouped_into 'aem' }
end

# there is a commit to change the service to aem. https://github.com/bstopp/puppet-aem/commit/a28d87fbf6bafc81ff00dec1759d8848708f32af
describe service('aem-aem') do
  it { should be_enabled }
  it { should be_running }
end

describe port(aem_port) do
  it { should be_listening }
end
