require 'spec_helper'
describe 'config::java' do
  context 'with defaults for all parameters' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('config') }
    it { is_expected.to contain_class('config::base') }
    it { is_expected.to contain_class('config::java') }
    it { is_expected.to contain_exec('/sbin/ldconfig') }
    it { is_expected.to contain_file('/etc/ld.so.conf.d/99-libjvm.conf') }
    it { is_expected.to contain_java_ks('cqse-0:/usr/java/default/jre/lib/security/cacerts') }

    mbeans = [ 'garbage_collector', 'memory-heap', 'memory-nonheap', 'memory-permgen', ]
    mbeans.each do |mbean|
      it { is_expected.to contain_collectd__plugin__genericjmx__mbean(mbean) }
    end
  end
end
