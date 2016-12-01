require 'spec_helper'

describe file('/app') do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by 'ec2-user' }
  it { should be_grouped_into 'ec2-user' }
end