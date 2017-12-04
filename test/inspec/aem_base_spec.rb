require './spec_helper'

init_conf

describe package('nokogiri') do
  it { should be_installed.by('gem').with_version('1.6.8.1') }
end

describe package('ruby_aem') do
  it { should be_installed.by('gem').with_version('1.4.0') }
end
