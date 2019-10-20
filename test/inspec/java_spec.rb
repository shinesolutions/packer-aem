# frozen_string_literal: true

require './spec_helper'

init_conf

version = @hiera.lookup('aem_curator::install_java::jdk_version', nil, @scope)
version_update = @hiera.lookup('aem_curator::install_java::jdk_version_update', nil, @scope)
java_version = "1.#{version}.0_#{version_update}"

# TO-DO: the describe package needs to be replaced with a package variable
# to support multiple OS
describe package('tomcat') do
  it { should be_installed }
end

describe service('tomcat') do
  it { should_not be_enabled }
  it { should_not be_running }
end

describe command('java -version') do
  its(:stderr) { should match "[openjdk|java] version \"#{java_version}\"" }
  its(:exit_status) { should eq 0 }
end
