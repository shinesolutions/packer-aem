include ::config::base

include ::config::certs

include aem_curator::install_java

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_java { 'Setup CloudWatch for Java': }

  # At the end of doing all Cloudwatch actions we are stopping the CloudWatch agent
  # and removing the awslogs pid file but only on RedHat or CentOS systems.
  #
  # Related to https://github.com/shinesolutions/packer-aem/issues/192
  #
  case $::os['name'] {
    /^(CentOS|RedHat)$/: {
      exec { 'Stop Cloudwatchlogs agent':
        command => "systemctl stop ${::config::base::awslogs_service_name}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        before  =>  File["${::config::base::awslogs_path}/state/awslogs.pid"]
      } -> file {"${::config::base::awslogs_path}/state/awslogs.pid":
        ensure => absent,
        require => Exec['Stop Cloudwatchlogs agent']
      }
    }
    default: { notify("Skipping awslogs stop and pid file removal") }
  }
}



if $::config::base::install_cloudwatch_metric_agent {
  config::cloudwatch_metric_agent { 'Setup Cloudwatch Metric Agent for Java':
    disk_path => [
      $::config::base::metric_root_disk_path
    ]
  }
}

include config::tomcat
