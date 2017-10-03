require 'spec_helper'

describe 'config::dispatcher' do
  context 'with defaults for all parameters' do
    it { is_expected.to compile }

    it { is_expected.to contain_class('config') }
    it { is_expected.to contain_class('config::base') }
    it { is_expected.to contain_class('config::dispatcher') }

    it { is_expected.to contain_file('/tmp/aem_certs') }
    it { is_expected.to contain_archive('/tmp/aem_certs/aem.cert') }
    it { is_expected.to contain_archive('/tmp/aem_certs/aem.key') }

    it { is_expected.to contain_concat('/etc/ssl/aem.unified-dispatcher.cert') }
    it { is_expected.to contain_concat__fragment('/etc/ssl/aem.unified-dispatcher.cert:cert') }
    it { is_expected.to contain_concat__fragment('/etc/ssl/aem.unified-dispatcher.cert:key') }

    it { is_expected.to contain_class('apache') }
    it { is_expected.to contain_class('apache::mod::ssl') }
    it { is_expected.to contain_class('apache::mod::headers') }

    it { is_expected.to contain_archive('dispatcher-apache2.4-linux-x86-64-ssl-4.2.2.tar.gz') }
    it { is_expected.to contain_class('aem::dispatcher') }

    it { is_expected.to contain_file('/var/www/html') }

    # These are treated differently by different versions of Puppet.
    if Puppet.version =~ /4\.[4567]\.[0-9]+/
      it { is_expected.to contain_apache__listen('80') }
      it { is_expected.to contain_apache__namevirtualhost('*:80') }
    end
  end
end
