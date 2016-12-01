require 'spec_helper'

app_dir = @properties['base::app_dir']
aws_user = @properties['base::aws_user']
aws_group = @properties['base::aws_group']

describe file(app_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by "#{aws_user}" }
  it { should be_grouped_into "#{aws_group}" }
end
