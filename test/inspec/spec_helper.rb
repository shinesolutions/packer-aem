require 'facter'
require 'hiera'

def init_conf
  @scope = {
    '::packer_build_name' => Facter.value(:packer_build_name),
    '::os' => Facter.value(:os),
  }
  @hiera = Hiera.new(:config => Facter.value(:packer_staging_dir) + '/hiera.yaml')
end
