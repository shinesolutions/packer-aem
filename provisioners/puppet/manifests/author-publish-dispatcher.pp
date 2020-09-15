# include ::config::base
class { 'config::base':
  before => [
    Class['config::certs'],
    Class['config::license'],
    Class['aem_curator::install_aem_java'],
    Class['aem_curator::install_author'],
    Class['aem_curator::install_publish'],
    Class['Aem_curator::Install_dispatcher']
  ]
}

class { 'config::certs':
  require => [
    Class['config::base']
  ],
  before  => [
    Class['aem_curator::install_aem_java'],
    Class['aem_curator::install_author'],
    Class['aem_curator::install_publish'],
    Class['Aem_curator::Install_dispatcher']
  ]
}

class {'config::license':
  require => [
    Class['config::base']
  ],
  before  => [
    Class['aem_curator::install_aem_java'],
    Class['aem_curator::install_author'],
    Class['aem_curator::install_publish'],
    Class['Aem_curator::Install_dispatcher']
  ]
}

class {'aem_curator::install_aem_java':
  require => [
    Class['config::base'],
    Class['config::certs'],
    Class['config::license']
  ],
  before  => [
    Class['aem_curator::install_author'],
    Class['aem_curator::install_publish'],
    Class['Aem_curator::Install_dispatcher']
  ]
}

class {'aem_curator::install_author':
  require => [
    Class['config::base'],
    Class['config::certs'],
    Class['config::license'],
    Class['aem_curator::install_aem_java']
  ],
  before  => [
    Class['aem_curator::install_publish'],
    Class['Aem_curator::Install_dispatcher']
  ]
}

class {'aem_curator::install_publish':
  require => [
    Class['config::base'],
    Class['config::certs'],
    Class['config::license'],
    Class['aem_curator::install_aem_java'],
    Class['aem_curator::install_author']
  ],
  before  => [
    Class['Aem_curator::Install_dispatcher']
  ]
}

if $::config::base::install_cloudwatchlogs {
  if $::config::base::install_cloudwatchlogs_aem {
    config::cloudwatchlogs_aem { 'author: Setup CloudWatch for AEM Author':
      aem_id => 'author',
    }
    config::cloudwatchlogs_aem { 'publish: Setup CloudWatch for AEM Publish':
      aem_id => 'publish',
    }
  }

  if $::config::base::install_cloudwatchlogs_httpd {
    config::cloudwatchlogs_httpd { 'Setup CloudWatch for Dispatcher':
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

include aem_curator::install_dispatcher

if $::config::base::install_collectd {
  config::collectd_jmx { 'Setup collectd-generic-jmx plugin': }
}
