class { 'config::base':
  before => [
    Class['config::certs'],
    Class['config::license'],
    Class['aem_curator::install_aem_java'],
    Class['aem_curator::install_author']
  ]
}

class { 'config::certs':
  require => [
    Class['config::base']
  ],
  before  => [
    Class['aem_curator::install_aem_java'],
    Class['aem_curator::install_author']
  ]
}

class {'config::license':
  require => [
    Class['config::base']
  ],
  before  => [
    Class['aem_curator::install_aem_java'],
    Class['aem_curator::install_author']
  ]
}

class {'aem_curator::install_aem_java':
  require => [
    Class['config::base'],
    Class['config::certs'],
    Class['config::license']
  ],
  before  => [
    Class['aem_curator::install_author']
  ]
}

include aem_curator::install_author

if $::config::base::install_cloudwatchlogs {
  if $::config::base::install_cloudwatchlogs_aem {
    config::cloudwatchlogs_aem { 'Setup CloudWatch for AEM Author':
      aem_id => 'author',
    }
  }

  # At the end of doing all Cloudwatch actions we are disabling and stopping the
  # CloudWatch agent, and removing the awslogs pid & state file.
  # Related to https://github.com/shinesolutions/packer-aem/issues/192
  exec { 'Disable Cloudwatchlogs agent':
    command => "systemctl disable ${::config::base::awslogs_service_name}",
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    before  => Exec['Stop Cloudwatchlogs agent'],
    require => Service[$::config::base::awslogs_service_name],
  } -> exec { 'Stop Cloudwatchlogs agent':
    command => "systemctl stop ${::config::base::awslogs_service_name}",
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    before  =>  [
                  File["${::config::base::awslogs_path}/state/awslogs.pid"],
                  File["${::config::base::awslogs_path}/state/agent-state"],
                ],
    require => Exec['Disable Cloudwatchlogs agent'],
  } -> file {"${::config::base::awslogs_path}/state/awslogs.pid":
    ensure  => absent,
    require => Exec['Stop Cloudwatchlogs agent'],
  } -> file {"${::config::base::awslogs_path}/state/agent-state":
    ensure  => absent,
    require => Exec['Stop Cloudwatchlogs agent'],
  }
}

package { 'perl-Digest-SHA':
  ensure => present,
}
class { '::cloudwatch':
    enable_mem_util         => true,
    enable_mem_used         => true,
    enable_mem_avail        => true,
    enable_disk_space_util  => true,
    enable_disk_space_used  => true,
    enable_disk_space_avail => true,
    enable_swap_util        => false,
    enable_swap_used        => false,
    auto_scaling            => false,
    cron_min                => '*',
    disk_path               => [
      $::config::base::metric_root_disk_path,
      $::config::base::metric_data_disk_path
    ],
    zip_url                 => 'https://github.com/shinesolutions/aws-scripts-mon/releases/download/1.3.0/shinesolutions-aws-scripts-mon-1.3.0.zip',
  }

if $::config::base::install_collectd {
  config::collectd_jmx { '[author] Setup collectd-generic-jmx plugin':
    require           => [
      Class['config::certs'],
      Class['aem_curator::install_aem_java'],
      Class['aem_curator::install_author'],
    ],
    aem_id            => 'author',
    # Loading JDK File name from hiera
    jdk_filename      => hiera('aem_curator::install_aem_java::jdk_filename'),
    # Loading JMX Keystore Path from the hiera parameter aem_keystore_path, to ensure
    # we are using the same location for the JMX
    jmx_keystore_path => dirname(hiera('aem_curator::install_author::aem_keystore_path')),
    tmp_dir           => hiera('tmp_dir'),
  }
}

