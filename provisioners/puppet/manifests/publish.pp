class publish (
  $tmp_dir,
  $aem_quickstart_source,
  $aem_license_source,
  $aem_healthcheck_version,
  $aem_base           = '/opt',
  $aem_jvm_mem_opts   = '-Xmx4096m',
  $aem_port           = '4503',
  $aem_sample_content = false
) {

  stage { 'test':
    require => Stage['main']
  }
  stage { 'shutdown':
    require => Stage['test'],
  }

  file { "${aem_base}/aem":
    ensure => directory,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  file { "${aem_base}/aem/publish":
    ensure  => directory,
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => File["${aem_base}/aem"],
  }

  # Retrieve the cq-quickstart jar and move into aem/publish directory
  archive { "${aem_base}/aem/publish/aem-publish-${aem_port}.jar":
    ensure  => present,
    source  => $aem_quickstart_source,
    cleanup => false,
    require => File["${aem_base}/aem/publish"],
  } ->
    file { "${aem_base}/aem/publish/aem-publish-${aem_port}.jar":
      ensure  => file,
      mode    => '0775',
      owner   => 'aem',
      group   => 'aem',
      require => File["${aem_base}/aem/publish"],
    }

  # Retrieve the license file and move into aem/publish directory
  archive { "${aem_base}/aem/publish/license.properties":
    ensure  => present,
    source  => "${aem_license_source}",
    cleanup => false,
    require => File["${aem_base}/aem/publish"],
  } ->
    file { "${aem_base}/aem/publish/license.properties":
      ensure => file,
      mode   => '0440',
      owner  => 'aem',
      group  => 'aem',
    }

  aem::instance { 'aem':
    source         => "${aem_base}/aem/publish/aem-publish-${aem_port}.jar",
    home           => "${aem_base}/aem/publish",
    type           => 'publish',
    port           => $aem_port,
    sample_content => $aem_sample_content,
    jvm_mem_opts   => $aem_jvm_mem_opts,
    jvm_opts       => '-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime -XX:+HeapDumpOnOutOfMemoryError',
    status         => 'running',
  }

  file { '/etc/puppetlabs/puppet/aem.yaml':
    ensure  => file,
    content => epp("${tmp_dir}/templates/aem.yaml.epp", { 'port' => $aem_port }),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  # Confirm AEM Starts up and the login page is ready.
  aem_aem { 'Wait until login page is ready':
    ensure  => login_page_is_ready,
    require => [Aem::Instance['aem'], File['/etc/puppetlabs/puppet/aem.yaml']],
  }

  class { 'aem_resources::create_system_users':
    require => [Aem_aem['Wait until login page is ready']],
  }

  aem_package { 'Install AEM Healthcheck Content Package':
    ensure    => present,
    name      => 'aem-healthcheck-content',
    group     => 'shinesolutions',
    version   => "${aem_healthcheck_version}",
    path      => "${aem_base}/aem",
    replicate => false,
    activate  => false,
    force     => true,
    require   => [Aem_aem['Wait until login page is ready']],
  }

  file { "${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip":
    ensure  => absent,
    require => Aem_package['Install AEM Healthcheck Content Package'],
  }

  # Ensure login page is still ready after all provisioning steps and before stopping AEM.
  aem_aem { 'Ensure login page is ready':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 30,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
    require                    => [
      Class['aem_resources::create_system_users'],
      File["${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip"],
    ]
  }

  class { 'serverspec':
    stage             => 'test',
    component         => 'publish',
    staging_directory => "${tmp_dir}/packer-puppet-masterless-publish",
    tries             => 5,
    try_sleep         => 3,
  }

  class { 'publish_shutdown':
    stage => 'shutdown',
  }

}

class publish_shutdown {

  exec { 'service aem-aem stop':
    cwd  => "${publish::tmp_dir}",
    path => ['/sbin','/usr/bin', '/usr/sbin'],
  }

}

include publish
