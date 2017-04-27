require 'spec_helper'

describe package('nokogiri') do
  it { should be_installed.by('gem').with_version('1.6.8.1') }
end

describe package('ruby_aem') do
  it { should be_installed.by('gem').with_version('1.0.18') }
end
