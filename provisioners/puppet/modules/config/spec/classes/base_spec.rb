require 'spec_helper'
describe 'config::base' do
  context 'with defaults for all parameters' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('config::base') }
    it { is_expected.to contain_file_line('sudo_rule_keep_proxy_vairables') }
    it { is_expected.to contain_archive('/tmp/collectd-cloudwatch.tar.gz') }
    it { is_expected.to contain_file('/opt/collectd-cloudwatch') }
    it { is_expected.to contain_file('/usr/share/collectd/jmx.db') }

    system_packages = [ 'python27', 'python27-pip', 'python27-cheetah', ]
    python_modules = [ 'awscli', 'boto3', 'requests', 'retrying', 'sh' ]

    system_packages.each do |pkg|
      it { is_expected.to contain_package(pkg) }
    end

    python_modules.each do |pkg|
      it { is_expected.to contain_package(pkg).with_provider('pip') }
    end

    collectd_plugins = [ 'cpu', 'interface', 'load', 'memory', 'syslog', ]
    collectd_plugins.each do |plugin|
      it { is_expected.to contain_collectd__plugin(plugin) }
    end
    it { is_expected.to contain_collectd__plugin__python__module('cloudwatch_writer') }

    cloudwatch_memory_stats = [ 'used', 'buffered', 'cached', 'free', ]
    cloudwatch_memory_stats.each do |stat|
      it { is_expected.to contain_file_line("#{stat} memory") }
    end
  end
end
