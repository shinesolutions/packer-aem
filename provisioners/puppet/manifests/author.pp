class author (
  $tmp_dir,
  $aem_quickstart_source,
  $aem_license_source,
  $aem_artifacts_base,
  $aem_healthcheck_version,
  $aem_repo_mount_point,
  $aem_base           = '/opt',
  $aem_jvm_mem_opts   = '-Xss4m -Xmx8192m',
  $aem_port           = '4502',
  $aem_sample_content = false,
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

  file { "${aem_base}/aem/author":
    ensure  => directory,
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => File["${aem_base}/aem"],
  }

  archive { "${aem_base}/aem/author/aem-author-${aem_port}.jar":
    ensure  => present,
    source  => $aem_quickstart_source,
    cleanup => false,
    require => File["${aem_base}/aem/author"],
  } -> file { "${aem_base}/aem/author/aem-author-${aem_port}.jar":
    ensure => file,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  # Set up configuration file for puppet-aem-resources.
  file { '/etc/puppetlabs/puppet/aem.yaml':
    ensure  => file,
    content => epp("${tmp_dir}/templates/aem.yaml.epp", { 'port' => $aem_port }),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  archive { "${aem_base}/aem/author/license.properties":
    ensure  => present,
    source  => "${aem_license_source}",
    cleanup => false,
    require => File["${aem_base}/aem/author"],
  } -> file { "${aem_base}/aem/author/license.properties":
    ensure => file,
    mode   => '0440',
    owner  => 'aem',
    group  => 'aem',
  }

  aem::instance { 'aem':
    source         => "${aem_base}/aem/author/aem-author-${aem_port}.jar",
    home           => "${aem_base}/aem/author",
    type           => 'author',
    port           => $aem_port,
    sample_content => $aem_sample_content,
    jvm_mem_opts   => $aem_jvm_mem_opts,
    jvm_opts       => '-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime -XX:+HeapDumpOnOutOfMemoryError -Dcom.sun.management.jmxremote.port=8463 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false',
    status         => 'running',
  } -> aem_aem { 'Wait until login page is ready':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> archive { "${tmp_dir}/cq-6.2.0-hotfix-11490-1.2.zip":
    ensure  => present,
    source  => "${aem_artifacts_base}/cq-6.2.0-hotfix-11490-1.2.zip",
    cleanup => false,
  } -> aem_package { 'Install hotfix 11490':
    ensure    => present,
    name      => 'cq-6.2.0-hotfix-11490',
    group     => 'adobe/cq620/hotfix',
    version   => '1.2',
    path      => "${tmp_dir}",
    replicate => false,
    activate  => false,
    force     => true,
  } -> archive { "${tmp_dir}/cq-6.2.0-hotfix-12785-7.0.zip":
    ensure  => present,
    source  => "${aem_artifacts_base}/cq-6.2.0-hotfix-12785-7.0.zip",
    cleanup => false,
  } -> aem_package { 'Install hotfix 12785':
    ensure    => present,
    name      => 'cq-6.2.0-hotfix-12785',
    group     => 'adobe/cq620/hotfix',
    version   => '7.0',
    path      => "${tmp_dir}",
    replicate => false,
    activate  => false,
    force     => true,
  } -> aem_aem { 'Wait until login page is ready post hotfix 12785 install':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> exec { 'Wait AEM post hotfix 12785 install':
    command => 'sleep 120',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> exec { 'Restart AEM post hotfix 12785 install':
    command => 'service aem-aem restart',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> exec { 'Wait AEM post hotfix 12785 restart':
    command => 'sleep 120',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> aem_aem { 'Wait until login page is ready post hotfix 12785 restart':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 120,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> archive { "${tmp_dir}/aem-service-pkg-6.2.SP1.zip":
    ensure  => present,
    source  => "${aem_artifacts_base}/AEM-6.2-Service-Pack-1-6.2.SP1.zip",
    cleanup => false,
  } -> aem_package { 'Install Service Pack 1':
    ensure                     => present,
    name                       => 'aem-service-pkg',
    group                      => 'adobe/cq620/servicepack',
    version                    => '6.2.SP1',
    path                       => "${tmp_dir}",
    replicate                  => false,
    activate                   => false,
    force                      => true,
    retries_max_tries          => 120,
    retries_base_sleep_seconds => 10,
    retries_max_sleep_seconds  => 10,
  } -> exec { 'Wait AEM post Service Pack 1 install':
    command => 'sleep 120',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> aem_aem { 'Wait until login page is ready post Service Pack 1 install':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> archive { "${tmp_dir}/cq-6.2.0-sp1-cfp-1.0.zip":
    ensure  => present,
    source  => "${aem_artifacts_base}/AEM-6.2-SP1-CFP1-1.0.zip",
    cleanup => false,
  } -> aem_package { 'Install Service Pack 1 Cumulative Fix Pack 1':
    ensure                     => present,
    name                       => 'cq-6.2.0-sp1-cfp',
    group                      => 'adobe/cq620/cumulativefixpack',
    version                    => '1.0',
    path                       => "${tmp_dir}",
    replicate                  => false,
    activate                   => false,
    force                      => true,
    retries_max_tries          => 120,
    retries_base_sleep_seconds => 10,
    retries_max_sleep_seconds  => 10,
  } -> exec { 'Wait AEM post Service Pack 1 Cumulative Fix Pack 1 install':
    command => 'sleep 120',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> aem_aem { 'Wait until login page is ready post Service Pack 1 Cumulative Fix Pack 1 install':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  }

  class { 'aem_resources::author_remove_default_agents':
    require => [Aem_aem['Wait until login page is ready post Service Pack 1 Cumulative Fix Pack 1 install']],
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
    require   => [Aem_aem['Wait until login page is ready post Service Pack 1 Cumulative Fix Pack 1 install']],
  } -> file { "${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip":
    ensure  => absent,
  }

  collectd::plugin::genericjmx::connection { 'java_app':
    host        => $::fqdn,
    service_url => 'service:jmx:rmi:///jndi/rmi://localhost:8463/jmxrmi',
    collect     => [ 'memory-heap', 'memory-nonheap', 'garbage_collector', 'memory-permgen' ],
  }

  # Ensure login page is still ready after all provisioning steps and before stopping AEM.
  aem_aem { 'Ensure login page is ready':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 30,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
    require                    => [
      Class['aem_resources::author_remove_default_agents'],
      File["${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip"],
    ]
  } -> class { 'serverspec':
    stage             => 'test',
    component         => 'author',
    staging_directory => "${tmp_dir}/packer-puppet-masterless-author",
    tries             => 5,
    try_sleep         => 3,
  }

  class { 'author_shutdown':
    stage => 'shutdown',
  }

}

class author_shutdown {

  exec { 'service aem-aem stop':
    cwd  => "${author::tmp_dir}",
    path => ['/usr/bin', '/usr/sbin'],
  }

  exec { "mv ${author::aem_base}/aem/author/crx-quickstart/repository/* ${author::aem_repo_mount_point}/":
    cwd  => "${author::tmp_dir}",
    path => '/usr/bin',
  } -> file { "${author::aem_base}/aem/author/crx-quickstart/repository/":
    ensure => 'link',
    owner  => 'aem',
    group  => 'aem',
    force  => true,
    target => "${author::aem_repo_mount_point}",
  }
}

include author
