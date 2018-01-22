require './spec_helper'

init_conf

describe package('ruby_aem') do
  it { should be_installed.by('gem').with_version('1.4.1') }
end
