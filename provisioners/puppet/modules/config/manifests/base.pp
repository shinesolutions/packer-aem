# == Class: config::base
#
# Basic configuration AEM AMIs
#
# === Parameters
#
# [*tmp_dir*]
#   A temporary directory used for staging
#
# [*python_package*]
# [*python_pip_package*]
# [*python_cheetah_package*]
#   System package manager names for the Python, pip and cheetah packages.
#
# [*rhn_register*]
#   Boolean that determines whether the instance should be registered with the RedHat Network.
#
# [*disable_selinux*]
#   Boolean that determines whether SELinux is disabled.
#
# [*install_aws_cli*]
#   Boolean that determines whether `awscli` will be installed.
#
# [*install_cloudwatchlogs*]
#   Boolean that determines whether `cloudwatchlogs` will be installed.
#
# [*install_collectd*]
#   Boolean that determines whether `collectd` will be installed.
#
# [*collectd_cloudwatch_source_url*]
#   URL to a `.tar.gz` file of the `collectd-cloudwatch` source.
#
# [*cloudwatchlogs_logfiles*]
#   A hash of `cloudwatchlogs::log` resources that's passed as the second
#   argument to `create_resources`. The keys should be log file paths and the
#   values should be a hash of `cloudwatchlogs::log` resource properties.
#
# [*cloudwatchlogs_logfiles_defaults*]
#   A hash of `cloudwatchlogs::log` resource properties that's passed as the
#   third argument to `create_resources`.
#
# === Authors
#
# James Sinclair <james.sinclair@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017 Shine Solutions Group, unless otherwise noted.
#
class config::base (
  $tmp_dir,
  $python_package,
  $python_pip_package,
  $python_cheetah_package,
  $rhn_register = false,
  $disable_selinux = true,
  $install_aws_cli = true,
  $install_cloudwatchlogs = true,
  $install_collectd = true,
  $collectd_cloudwatch_source_url = 'https://github.com/awslabs/collectd-cloudwatch/archive/master.tar.gz',

  $cloudwatchlogs_logfiles          = {},
  $cloudwatchlogs_logfiles_defaults = {},
  $install_amazon_ssm_agent = true
){
  require ::config

  class { '::timezone': }

  if ($::osfamily == 'redhat') and ($::operatingsystem != 'Amazon') {

    if $rhn_register {
      class { '::rhn_register':
        use_classic => false,
      }
    }

    if $disable_selinux {
      # issue with selinux stopping aem:dispatcher to start. https://github.com/bstopp/puppet-aem/issues/73
      class { '::selinux':
        mode => 'disabled',
      }
    }
  }

  file_line { 'sudo_rule_keep_proxy_vairables':
    path => '/etc/sudoers',
    line => 'Defaults    env_keep += "ftp_proxy http_proxy https_proxy no_proxy"',
  }

  package { [ $python_package, $python_pip_package, $python_cheetah_package ]:
    ensure => latest,
  }

  package { [ 'boto3', 'requests', 'retrying', 'sh' ]:
    ensure   => latest,
    provider => 'pip',
  }

  if $install_aws_cli {
    package { 'awscli':
      ensure   => latest,
      provider => 'pip',
    }
  }

  if $install_cloudwatchlogs {
    class { '::cloudwatchlogs': }
    Cloudwatchlogs::Log {
      notify => Service['awslogs'],
    }
    create_resources(
      cloudwatchlogs::log,
      $cloudwatchlogs_logfiles,
      $cloudwatchlogs_logfiles_defaults,
    )
  }

  if $install_collectd {
    $collectd_plugins = [
      'syslog', 'cpu', 'interface', 'load', 'memory',
    ]
    $collectd_jmx_types_path = '/usr/share/collectd/jmx.db'
    $collectd_cloudwatch_base_dir = '/opt/collectd-cloudwatch'
    file { '/opt/collectd-cloudwatch':
      ensure => directory,
    }
    archive { '/tmp/collectd-cloudwatch.tar.gz':
      extract       => true,
      extract_path  => $collectd_cloudwatch_base_dir,
      extract_flags => '--strip-components=1 -xvzf',
      creates       => "${collectd_cloudwatch_base_dir}/src/cloudwatch_writer.py",
      source        => $collectd_cloudwatch_source_url,
      cleanup       => true,
    }
    class { '::collectd':
      purge           => true,
      recurse         => true,
      purge_config    => true,
      minimum_version => '5.4',
      package_ensure  => latest,
      service_ensure  => stopped,
      service_enable  => false,
      typesdb         => [
        '/usr/share/collectd/types.db',
        $collectd_jmx_types_path,
      ],
    }
    file { $collectd_jmx_types_path:
      ensure  => present,
      content => file('config/collectd_jmx_types.db'),
      require => Package[$::collectd::install::package_name],
    }
    collectd::plugin { $collectd_plugins:
      ensure => present,
    }
    class { '::collectd::plugin::python':
      modulepaths => [
        '/usr/lib/python2.7/dist-packages',
        '/usr/local/lib/python2.7/site-packages',
        "${collectd_cloudwatch_base_dir}/src",
      ],
      logtraces   => true,
    }
    collectd::plugin::python::module {'cloudwatch_writer':
      script_source => 'puppet:///modules/config/cloudwatch_writer.py',
    }
    $cloudwatch_memory_stats = [
      'used', 'buffered', 'cached', 'free',
    ]
    $cloudwatch_memory_stats.each |$stat| {
      file_line { "${stat} memory":
        ensure  => present,
        line    => "memory--memory-${stat}",
        path    => "${collectd_cloudwatch_base_dir}/src/cloudwatch/config/whitelist.conf",
        require => Collectd::Plugin::Python::Module['cloudwatch_writer'],
      }
    }
  }

  if $install_amazon_ssm_agent {
    include amazon_ssm_agent
  }
}
