# frozen_string_literal: true

require './spec_helper'

init_conf

jdk_filename = @hiera.lookup('aem_curator::install_java::jdk_filename', nil, @scope).split('-')

case jdk_filename[1]
when match(/^8\w*/)
  java = jdk_filename[1].split('u')
  java_version = "1.#{java[0]}.0_#{java[1]}"
when match(/^11\S*/)
  java = jdk_filename[1].split('_')
  java_version = java[0]
else
  puts 'Specify the correct java filename.'
end

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
