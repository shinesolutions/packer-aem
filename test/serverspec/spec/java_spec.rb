require 'spec_helper'

version = @hiera.lookup('oracle_java::version', nil, @scope)
version_update = @hiera.lookup('oracle_java::version_update', nil, @scope)

java_version = "1.#{version}.0_#{version_update}"

describe command('java -version') do
  its(:stderr) { should match "openjdk version \"#{java_version}\"" }
  its(:exit_status) { should eq 0 }
end
