require 'rspec-puppet/spec_helper'
require 'puppetlabs_spec_helper/module_spec_helper'

base_dir = File.dirname(File.expand_path(__FILE__))

Puppet::Util::Log.level = :debug
Puppet::Util::Log.newdestination(:console)

RSpec.configure do |c|
  c.module_path     = File.join(base_dir, 'fixtures', 'modules')
  c.manifest_dir    = File.join(base_dir, 'fixtures', 'manifests')
  c.hiera_config    = File.join(base_dir, 'fixtures', 'hiera.yaml')
  c.environmentpath = File.join(Dir.pwd, 'spec')

  default_facts = {
    puppetversion: Puppet.version,
    facterversion: Facter.version
  }

  fact_files = [ 'default_facts.yaml', 'default_module_facts.yaml' ]
  fact_files.each do |fact_file|
    file_path = File.expand_path("../#{fact_file}", __FILE__)
    default_facts.merge!(YAML.load(File.read(file_path))) if File.exist?(file_path)
  end

  c.default_facts = default_facts

  # Coverage generation
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
