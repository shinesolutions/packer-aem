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

describe file("#{aem_base}/aem/aem-healthcheck-content-1.2.zip") do
  it { should be_file }
  it { should exist }
  it { should be_mode 664 }
  it { should be_owned_by "#{packer_user}" }
  it { should be_grouped_into "#{packer_group}" }
end
