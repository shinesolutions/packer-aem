require 'spec_helper'
require 'aem_spec_helper'

describe 'config::publish' do
  context 'with defaults for all parameters' do
    it { is_expected.to contain_class('config::publish') }
    it_behaves_like 'aem', 'publish', '4503'
  end
end
