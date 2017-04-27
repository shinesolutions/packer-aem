require 'spec_helper'
describe 'config::dispatcher' do
  context 'with defaults for all parameters' do
    it { is_expected.to compile }

    it { is_expected.to contain_class('config') }
    it { is_expected.to contain_class('config::base') }
    it { is_expected.to contain_class('config::dispatcher') }
    it { is_expected.to contain_archive('dispatcher-apache2.4-linux-x86-64-4.2.2.tar.gz') }
    it { is_expected.to contain_exec('httpd -k graceful') }
    it { is_expected.to contain_file('/tmp/shinesolutions/packer-aem') }

    # These are treated differently by different versions of Puppet.
    if Puppet.version =~ /4\.[4567]\.[0-9]+/
      it { is_expected.to contain_apache__listen('80') }
      it { is_expected.to contain_apache__namevirtualhost('*:80') }
    end
  end
end
