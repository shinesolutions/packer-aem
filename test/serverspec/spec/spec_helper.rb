require 'serverspec'
require 'yaml'

set :backend, :exec

@properties = YAML.load_file('/tmp/hieradata/common.yaml')
