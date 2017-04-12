require 'spec_helper'
describe 'config::dispatcher' do
  context 'with defaults for all parameters' do
    it { is_expected.to compile }

    it { is_expected.to contain_class('config::dispatcher') }
    it { is_expected.to contain_archive('dispatcher-apache2.4-linux-x86-64-4.2.2.tar.gz') }
    it { is_expected.to contain_exec('httpd -k graceful') }
    it { is_expected.to contain_file('/tmp/shinesolutions/packer-aem') }
  end
end
