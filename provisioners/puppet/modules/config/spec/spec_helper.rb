require 'rspec-puppet/spec_helper'
require 'puppetlabs_spec_helper/module_spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

Puppet::Util::Log.level = :debug
Puppet::Util::Log.newdestination(:console)

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.hiera_config = File.join(__FILE__, '..', '..', 'hiera.yaml')
  default_facts = {
    puppetversion: Puppet.version,
    facterversion: Facter.version
  }

  fact_files = [ 'default_facts.yaml', 'default_module_facts.yaml' ]
  fact_files.each do |fact_file|
    file_path = File.expand_path("../#{fact_file}", __FILE__)
    puts file_path
    default_facts.merge!(YAML.load(File.read(file_path))) if File.exist?(file_path)
  end

  c.default_facts = default_facts
end
