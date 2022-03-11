# frozen_string_literal: true

require 'facter'
require 'hiera'

def init_conf
  @scope = {
    '::packer_build_name' => Facter.value(:packer_build_name),
    '::packer_staging_dir' => Facter.value(:packer_staging_dir),
    '::os' => Facter.value(:os)
  }
  # TODO: Fix this when inspec has a path from hiera 3 to 5. More Details: https://tickets.puppetlabs.com/browse/HI-598
  @hiera = Hiera.new(
    # Disable packer_staging_dir usage due to nil value being returned since Puppet upgrade to 7.9.0,
    # replace with string containing the staging directory value for the time being
    # config: @scope['::packer_staging_dir'] + '/hiera3.yaml'
    config: '/tmp/shinesolutions/packer-aem/hiera3.yaml'
  )
end
