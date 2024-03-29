# == Class: config::base
#
# Basic configuration AEM AMIs
#
# === Parameters
#
# [*tmp_dir*]
#   A temporary directory used for staging
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
# [*install_amazon_ssm_agent*]
#   Boolean that determines whether the Amazon SSM Agent will be installed.
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
# [*collectd_packages*]
#   An array of extra packages to install when installing collectd.
#
# [*http_proxy*]
#   Http proxy setting should cloudwatch logs need to communicate via a proxy
#   Default value: undef
#
# [*https_proxy*]
#   Https proxy setting should cloudwatch logs need to communicate via a proxy
#   Default value: undef
#
# [*no_proxy*]
#   No proxy setting should cloudwatch logs need to communicate via a proxy
#   Default value: undef
#
# [*os_package_manager_packages*]
#   List of packages which should be installed with OS default package manager.
#
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
  $os_package_manager_packages,
  $awslogs_service_name,
  $awslogs_proxy_path,
  $awslogs_path,
  $base_dir                         = '/opt/shinesolutions',
  $virtualenv_dir                   = '/home/.virtualenvs',
  $rhn_register                     = false,
  $disable_selinux                  = true,
  $install_aws_cli                  = true,
  $install_virtualenvs              = true,
  $install_cloudwatchlogs           = true,
  $install_cloudwatchlogs_aem       = true,
  $install_cloudwatchlogs_httpd     = true,
  $install_cloudwatchlogs_java      = true,
  $install_collectd                 = true,
  $install_rng_tools                = true,
  $install_amazon_ssm_agent         = true,
  $install_cloudwatch_metric_agent  = true,
  $metric_root_disk_path            = '',
  $metric_data_disk_path            = '',
  $collectd_cloudwatch_source_url   = 'https://github.com/awslabs/collectd-cloudwatch/archive/master.tar.gz',
  $cloudwatchlogs_logfiles          = {},
  $cloudwatchlogs_logfiles_defaults = {},
  $collectd_packages                = [],
  $http_proxy                       = undef,
  $https_proxy                      = undef,
  $no_proxy                         = undef,
) {
  require ::config

  class { '::timezone': }

  file { $tmp_dir:
    ensure => directory,
    mode   => '0700',
  }

  file { $base_dir:
    ensure => directory,
    mode   => '0755',
  }

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

  file_line { 'sudo_rule_keep_proxy_variables':
    path => '/etc/sudoers',
    line => 'Defaults    env_keep += "ftp_proxy http_proxy https_proxy no_proxy"',
  }

  package { $os_package_manager_packages:
    ensure => installed,
  }

  package { [ 'requests', 'retrying', 'sh' ]:
    ensure   => latest,
    provider => 'pip3',
  }

  if $install_aws_cli {
    package { 'awscli':
      ensure   => '1.16.10',
      provider => 'pip3',
    } -> file { '/bin/aws':
      ensure => link,
      owner  => 'root',
      group  => 'root',
      target => '/usr/local/bin/aws',
    }
  }
  # allow awscli to control boto version if it's enabled, otherwise install
  package { 'boto':
    ensure   => present,
    provider => 'pip3',
  }

  package { 'boto3':
    ensure   => '1.8.5',
    provider => 'pip3',
  }
  if $install_virtualenvs {
    config::python_virtualenv { 'Config base python virtualenvs installation':
      virtualenv_dir => $virtualenv_dir,
    }
  }
  if $install_rng_tools {
      package{'rng-tools':
        ensure   => present,
        provider => 'yum',
      } -> service{'rngd':
        ensure => running,
        enable => true,
      }
    }
  if $install_cloudwatchlogs {
    class { '::cloudwatchlogs': }
    Cloudwatchlogs::Log {
      notify => Service[$awslogs_service_name],
    }
    create_resources(
      cloudwatchlogs::log,
      $cloudwatchlogs_logfiles,
      $cloudwatchlogs_logfiles_defaults,
    )

    if defined('$http_proxy') {
      file_line { 'Set CloudWatch Proxy: http_proxy':
        path      => $awslogs_proxy_path,
        line      => "HTTP_PROXY=${http_proxy}",
        match     => '^HTTP_PROXY=.*$',
        subscribe => Service[$awslogs_service_name],
      }
    }
    if defined('$https_proxy') {
      file_line { 'Set CloudWatch Proxy: https_proxy':
        path      => $awslogs_proxy_path,
        line      => "HTTPS_PROXY=${https_proxy}",
        match     => '^HTTPS_PROXY=.*$',
        subscribe => Service[$awslogs_service_name],
      }
    }
    if defined('$no_proxy') {
      file_line { 'Set CloudWatch Proxy: no_proxy':
        path      => $awslogs_proxy_path,
        line      => "NO_PROXY=${no_proxy}",
        match     => '^NO_PROXY=.*$',
        subscribe => Service[$awslogs_service_name],
      }
    }

  }

  if $install_collectd {
    $collectd_plugins = [
      'syslog', 'cpu', 'interface', 'load', 'memory'
    ]
    package { $collectd_packages:
      ensure => installed,
    }
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
    collectd::typesdb { $collectd_jmx_types_path:
      mode => '0644'
    }
    collectd::type { 'jmx_memory':
      target  => $collectd_jmx_types_path,
      ds_type => 'GAUGE',
      min     => 0,
      max     => 'U',
      ds_name => 'value',
    }
    collectd::type { 'file_handles':
      target  => $collectd_jmx_types_path,
      ds_type => 'GAUGE',
      min     => 0,
      max     => 'U',
      ds_name => 'value',
    }
    collectd::type { 'time_ms':
      target  => $collectd_jmx_types_path,
      ds_type => 'GAUGE',
      min     => 0,
      max     => 'U',
      ds_name => 'value',
    }

    collectd::plugin { $collectd_plugins:
      ensure => present,
    }
    # Force disabling the installation of collectd-python plugin for amazon-linux 2
    if ($facts['os']['name'] == 'Amazon' and versioncmp($facts['os']['release']['major'],'2') >= 0) {
      $manage_package_collectd_python = false
    } else  {
    # Falling back to the default of the puppet-module puppet-collectd which is true for amazon-linux 1 & RHEL8
      $manage_package_collectd_python = undef
    }
    class { '::collectd::plugin::python':
      manage_package => $manage_package_collectd_python,
      modulepaths    => [
        "${collectd_cloudwatch_base_dir}/src",
      ],
      logtraces      => true,
    }
    collectd::plugin::python::module {'cloudwatch_writer':
      modulepath    => "${collectd_cloudwatch_base_dir}/src",
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
    include ::amazon_ssm_agent
  }
}
