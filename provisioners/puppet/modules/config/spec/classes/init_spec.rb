require 'spec_helper'
describe 'config' do
  context 'with defaults for all parameters' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('config') }
    it { is_expected.to contain_host('test.example.com') }

    system_packages = [ 'gcc', 'ruby-devel', 'zlib-devel', ]
    gems = [ 'bundler', 'io-console', ]
    puppet_gems = [ 'nokogiri', 'ruby_aem', ]

    system_packages.each do |pkg|
      it { is_expected.to contain_package(pkg) }
    end

    gems.each do |pkg|
      it { is_expected.to contain_package(pkg).with_provider('gem') }
    end

    puppet_gems.each do |pkg|
      it { is_expected.to contain_package(pkg).with_provider('puppet_gem') }
    end
  end
end
