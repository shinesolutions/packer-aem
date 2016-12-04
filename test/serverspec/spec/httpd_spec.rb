require 'spec_helper'

describe service('httpd') do
  it { should be_enabled }
  it { should be_running }
end
