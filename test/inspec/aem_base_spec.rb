require './spec_helper'

init_conf

describe package('ruby_aem') do
  it { should be_installed.by('gem').with_version('2.0.0.beta.3') }
end

describe package('ruby_aem_aws') do
  it { should be_installed.by('gem').with_version('1.1.0') }
end
