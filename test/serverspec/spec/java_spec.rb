require 'spec_helper'

describe command('echo $JAVA_HOME /') do
  its(:stdout) { should match '/opt/jdk1.8.0_112' }
end

describe command('java -version /') do
  its(:stderr) { should match /java version "1.8.0_112"/ }
  its(:exit_status) { should eq 0 }
end
