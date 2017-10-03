require 'spec_helper'
describe 'config::aem_install_package' do
  context 'with required parameters' do
    let(:title) { 'package-name' }
    let(:params) {{
      :group          => 'package-group',
      :version        => 'package-version',
      :artifacts_base => 's3://bucket/prefix',
    }}

    it { is_expected.to compile() }
    it { is_expected.to contain_archive('/tmp/aem_install_tmp/package-name-package-version.zip') }
    it { is_expected.to contain_aem_package('Install package-name') }
    it { is_expected.to contain_aem_aem('Wait for login page post package-name') }
    it { is_expected.to contain_aem_aem('Wait until aem health check is ok post package-name') }
    it { is_expected.to contain_exec('Wait post install of package-name') }
    it { is_expected.to contain_exec('Wait post login page for package-name') }
    it { is_expected.to contain_file('/tmp/aem_install_tmp') }
  end
end
