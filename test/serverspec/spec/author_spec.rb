require 'spec_helper'

app_dir = @properties['base::app_dir']

describe file("#{app_dir}/aem") do
  it { should be_directory }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by 'aem' }
  it { should be_grouped_into 'aem' }
end

describe file("#{app_dir}/aem/author") do
  it { should be_directory }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by 'aem' }
  it { should be_grouped_into 'aem' }
end

describe file("#{app_dir}/aem/author/license.properties") do
  it { should be_file }
  it { should exist }
  it { should be_mode 440 }
  it { should be_owned_by 'aem' }
  it { should be_grouped_into 'aem' }
end

describe file("#{app_dir}/aem/author/aem-author-4502.jar") do
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

describe port(4502) do
  it { should be_listening }
end
