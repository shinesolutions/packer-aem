# frozen_string_literal: true

require 'facter'
require 'hiera'

def init_conf
  @scope = {
    '::packer_build_name' => Facter.value(:packer_build_name),
    '::os' => Facter.value(:os)
  }
  # TODO - Fix this when inspec has a path from hiera 3 to 5
  @hiera = Hiera.new(config: Facter.value(:packer_staging_dir) + '/hiera3.yaml')
end
