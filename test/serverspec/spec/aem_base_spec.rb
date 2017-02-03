require 'spec_helper'

aem_base = @hiera.lookup('aem_base::aem_base', nil, @scope)
aem_base ||= '/opt'

packer_user = @hiera.lookup('aem_base::packer_user', nil, @scope)
packer_group = @hiera.lookup('aem_base::packer_group', nil, @scope)

describe file("#{aem_base}/aem") do
  it { should be_directory }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by "#{packer_user}" }
  it { should be_grouped_into "#{packer_group}" }
end

describe file("#{aem_base}/aem/cq-quickstart.jar") do
  it { should be_file }
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by "#{packer_user}" }
  it { should be_grouped_into "#{packer_group}" }
end

describe package('nokogiri') do
  it { should be_installed.by('gem').with_version('1.6.8.1') }
end

describe package('ruby_aem') do
  it { should be_installed.by('gem').with_version('1.0.6') }
end
