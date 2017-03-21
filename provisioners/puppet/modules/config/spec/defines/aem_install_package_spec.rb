require 'spec_helper'
describe 'config::aem_install_package' do
  context 'with required parameters' do
    let(:title) { 'package-name' }
    let(:params) {{
      :group          => 'package-group',
      :version        => 'package-version',
      :artifacts_base => 's3://bucket/prefix',
    }}

    it { should compile() }
  end
end
