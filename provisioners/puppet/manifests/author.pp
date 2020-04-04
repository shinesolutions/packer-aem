include ::config::base

include ::config::certs

include ::config::license

include aem_curator::install_java

include aem_curator::install_author

if $::config::base::install_cloudwatchlogs {
  if $::config::base::install_cloudwatchlogs_aem {
    config::cloudwatchlogs_aem { 'Setup CloudWatch for AEM Author':
      aem_id => 'author',
    }
  }

  # At the end of doing all Cloudwatch actions we are disabling and stopping the
  # CloudWatch agent, and removing the awslogs pid file.
  # Related to https://github.com/shinesolutions/packer-aem/issues/192
  exec { 'Disable Cloudwatchlogs agent':
    command => "systemctl disable ${::config::base::awslogs_service_name}",
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    before  => Exec['Stop Cloudwatchlogs agent'],
    require => Service[$::config::base::awslogs_service_name],
  } -> exec { 'Stop Cloudwatchlogs agent':
    command => "systemctl stop ${::config::base::awslogs_service_name}",
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    before  => File["${::config::base::awslogs_path}/state/awslogs.pid"],
    require => Exec['Disable Cloudwatchlogs agent'],
  } -> file {"${::config::base::awslogs_path}/state/awslogs.pid":
    ensure  => absent,
    require => Exec['Stop Cloudwatchlogs agent']
  }
}

if $::config::base::install_collectd {
  config::collectd_jmx { 'Setup collectd-generic-jmx plugin': }
}

if $::config::base::install_cloudwatch_metric_agent {
  config::cloudwatch_metric_agent { 'Setup Cloudwatch Metric Agent for AEM Author':
    disk_path   => [
      $::config::base::metric_root_disk_path,
      $::config::base::metric_data_disk_path
    ],
    autoscaling => false
  }
}
