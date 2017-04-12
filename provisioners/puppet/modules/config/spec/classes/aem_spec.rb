require 'spec_helper'
require 'aem_spec_helper'

describe 'config::aem' do
  context 'with author role and port' do
    let(:params) {{
      :aem_role => 'author',
      :aem_port => '4502',
    }}

    it_behaves_like 'aem', 'author', '4502'
  end

  context 'with publisher role and port' do
    let(:params) {{
      :aem_role => 'publish',
      :aem_port => '4503',
    }}

    it_behaves_like 'aem', 'publish', '4503'
  end

  context 'with defaults for all parameters' do
    it { is_expected.to_not compile }
  end
end
