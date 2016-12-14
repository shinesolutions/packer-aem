require 'spec_helper'

version = @hiera.lookup('jdk_oracle::version', nil, @scope)
version_update = @hiera.lookup('jdk_oracle::version_update', nil, @scope)

java_version = "1.#{version}.0_#{version_update}"

describe command('java -version') do
  its(:stderr) { should match "java version \"#{java_version}\"" }
  its(:exit_status) { should eq 0 }
end
