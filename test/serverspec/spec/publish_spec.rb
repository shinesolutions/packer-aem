require 'spec_helper'

describe file('/opt/aem') do
  it { should be_directory }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by 'aem' }
  it { should be_grouped_into 'aem' }
end

describe file('/opt/aem/publish') do
  it { should be_directory }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by 'aem' }
  it { should be_grouped_into 'aem' }
end

describe file('/opt/aem/publish/license.properties') do
  it { should be_file }
  it { should exist }
  it { should be_mode 440 }
  it { should be_owned_by 'aem' }
  it { should be_grouped_into 'aem' }
end

describe file('/opt/aem/publish/aem-publish-4503.jar') do
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

describe port(4503) do
  it { should be_listening }
end
