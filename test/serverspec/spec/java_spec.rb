require 'spec_helper'

install_dir = @properties['jdk_oracle::install_dir']
version = @properties['jdk_oracle::version']
version_update = @properties['jdk_oracle::version_update']

java_version = "1.#{version}.0_#{version_update}"
java_home = "#{install_dir}/jdk#{java_version}"


describe command('echo $JAVA_HOME') do
  its(:stdout) { should match "#{java_home}" }
end

describe command('java -version') do
  its(:stderr) { should match "java version \"#{java_version}\"" }
  its(:exit_status) { should eq 0 }
end
