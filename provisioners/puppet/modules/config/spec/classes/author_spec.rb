require 'spec_helper'
require 'aem_spec_helper'

describe 'config::author' do
  context 'with defaults for all parameters' do
    it { is_expected.to contain_class('config::author') }
    it_behaves_like 'aem', 'author', '4502'
  end
end
