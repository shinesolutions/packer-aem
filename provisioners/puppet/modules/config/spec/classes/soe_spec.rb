require 'spec_helper'
describe 'config::soe' do
  context 'with defaults for all parameters' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('config') }
    it { is_expected.to contain_class('config::amz_linux_cis_benchmark') }
    it { is_expected.to contain_class('config::soe') }
  end
end
