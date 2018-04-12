require './spec_helper'

init_conf

describe package('ruby_aem') do
  it { should be_installed.by('gem').with_version('1.4.2') }
end

describe package('ruby_aem_aws') do
  it { should be_installed.by('gem').with_version('0.9.1') }
end
