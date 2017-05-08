require 'spec_helper'
describe 'config::base' do
  context 'with defaults for all parameters' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('config') }
    it { is_expected.to contain_class('config::base') }
    it { is_expected.to contain_file_line('sudo_rule_keep_proxy_vairables') }
    it { is_expected.to contain_archive('/tmp/collectd-cloudwatch.tar.gz') }
    it { is_expected.to contain_file('/opt/collectd-cloudwatch') }
    it { is_expected.to contain_file('/usr/share/collectd/jmx.db') }

    system_packages = [ 'python27', 'python27-pip', 'python27-cheetah', ]
    python_modules = [ 'awscli', 'boto3', 'requests', 'retrying', 'sh' ]
    util_packages = ['unzip', 'jq']

    system_packages.each do |pkg|
      it { is_expected.to contain_package(pkg) }
    end

    python_modules.each do |pkg|
      it { is_expected.to contain_package(pkg).with_provider('pip') }
    end

    util_packages.each do |pkg|
      it { is_expected.to contain_package(pkg).with_ensure('installed')}
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

    # These values are specific to the Amazon Linux module data. Not sure how
    # to test other versions.
    logfiles = [
      'amazon/ssm/errors.log', 'cloud-init-output.log', 'cloud-init.log',
      'cron', 'dmesg', 'maillog', 'messages', 'secure', 'yum.log',
    ]
    logfiles.each do |logfile|
      it { is_expected.to contain_cloudwatchlogs__log("/var/log/#{logfile}") }
    end

    # These are treated differently by different versions of Puppet.
    if Puppet.version =~ /4\.[45678]\.[0-9]+/
      it { is_expected.to contain_file('/opt/collectd-cloudwatch/src') }
      it { is_expected.to contain_file('/usr/lib/python2.7/dist-packages') }
      it { is_expected.to contain_file('/usr/local/lib/python2.7/site-packages') }
    end
  end

  context 'with proxy settings for awslogs' do
    let(:params ) {
      {
        :install_cloudwatchlogs => true,
        :proxy_server_name      => 'shinesolutions.com',
        :proxy_server_port      => '443'
      }
    }

    it {
      is_expected.to contain_file('/etc/awslogs/proxy.conf')
      .with(
        :ensure => 'present',
        :notify => 'Service[awslogs]',
      )
    }
  end
end
