require 'spec_helper'

describe package('nokogiri') do
  it { should be_installed.by('puppet_gem').with_version('1.6.8.1') }
end

describe package('ruby_aem') do
  it { should be_installed.by('puppet_gem').with_version('1.0.6') }
end
