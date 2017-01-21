require 'serverspec'
require 'facter'
require 'hiera'

set :backend, :exec

#TODO: consider: http://logicminds.github.io/blog/2016/01/16/testing-hiera-data/

@scope = {'::packer_build_name' => Facter.value(:packer_build_name)}

@hiera = Hiera.new(:config => Facter.value(:packer_staging_directory) + '/hiera.yaml')
