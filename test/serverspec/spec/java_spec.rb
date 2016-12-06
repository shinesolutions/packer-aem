require 'spec_helper'

version = @properties['jdk_oracle::version']
version_update = @properties['jdk_oracle::version_update']

java_version = "1.#{version}.0_#{version_update}"

describe command('java -version') do
  its(:stderr) { should match "java version \"#{java_version}\"" }
  its(:exit_status) { should eq 0 }
end
