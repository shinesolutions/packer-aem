# == Class: config::author
#
# Install AEM and configure for the `author` role.
#
# === Parameters
#
# [*tmp_dir*]
#   A temporary directory used for staging
#
# [*aem_quickstart_source*]
# [*aem_license_source*]
#   URLs (s3://, http:// or file://) for the AEM jar and license files.
#
# [*aem_healthcheck_version*]
#   The version of the AEM healthcheck service to install.
#
# [*aem_base*]
#   Base directory for installing AEM.
#
# [*aem_jvm_mem_opts*]
#   Extra memory options to be passed to the JVM.
#
# [*aem_port*]
#   TCP port AEM will listen on.
#
# [*aem_sample_content*]
#   Boolean that determines whether the AEM sample content should be installed.
#
# === Authors
#
# James Sinclair <james.sinclair@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017 Shine Solutions Group, unless otherwise noted.
#
class config::author (
  $tmp_dir,
  $aem_quickstart_source,
  $aem_license_source,
  $aem_healthcheck_version,
  $aem_base           = '/opt',
  $aem_jvm_mem_opts   = '-Xmx4096m',
  $aem_port           = '4502',
  $aem_sample_content = false
) {
  require ::config::java
#  require ::config::aem_base


  file { [ "${aem_base}/aem", "${aem_base}/aem/author" ]:
    ensure => directory,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  archive { "${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip":
    ensure  => present,
    source  => "http://central.maven.org/maven2/com/shinesolutions/aem-healthcheck-content/${aem_healthcheck_version}/aem-healthcheck-content-${aem_healthcheck_version}.zip",
    cleanup => false,
    require => File["${aem_base}/aem"],
  } ->
  file { "${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip":
    ensure => file,
    mode   => '0664',
  }

  # Retrieve the cq-quickstart jar and move into aem/author directory
  archive { "${aem_base}/aem/author/aem-author-${aem_port}.jar":
    ensure  => present,
    source  => $aem_quickstart_source,
    cleanup => false,
    require => File["${aem_base}/aem/author"],
  } ->
  file { "${aem_base}/aem/author/aem-author-${aem_port}.jar":
    ensure  => file,
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => File["${aem_base}/aem/author"],
  }

  # Retrieve the license file and move into aem/author directory
  archive { "${aem_base}/aem/author/license.properties":
    ensure  => present,
    source  => $aem_license_source,
    cleanup => false,
    require => File["${aem_base}/aem/author"],
  } ->
  file { "${aem_base}/aem/author/license.properties":
    ensure => file,
    mode   => '0440',
    owner  => 'aem',
    group  => 'aem',
  }

  $jvm_opts = [
    '-XX:+PrintGCDetails',
    '-XX:+PrintGCTimeStamps',
    '-XX:+PrintGCDateStamps',
    '-XX:+PrintTenuringDistribution',
    '-XX:+PrintGCApplicationStoppedTime',
    '-XX:+HeapDumpOnOutOfMemoryError',
  ]
  aem::instance { 'aem':
    source         => "${aem_base}/aem/author/aem-author-${aem_port}.jar",
    home           => "${aem_base}/aem/author",
    type           => 'author',
    port           => $aem_port,
    sample_content => $aem_sample_content,
    jvm_mem_opts   => $aem_jvm_mem_opts,
    jvm_opts       => $jvm_opts.join(' '),
    status         => 'running',
  }

  file { '/etc/puppetlabs/puppet/aem.yaml':
    ensure  => file,
    content => epp('config/aem.yaml.epp', { 'port' => $aem_port }),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  # Confirm AEM starts up and the login page is ready.
  aem_aem { 'Wait until login page is ready':
    ensure  => login_page_is_ready,
    require => [Aem::Instance['aem'], File['/etc/puppetlabs/puppet/aem.yaml']],
  }  ->
  exec {'Manual delay to let AEM ready':
    command => "sleep 120",
    path => ['/bin', '/usr/bin'],
  }

  class { '::aem_resources::author_remove_default_agents':
    require => [Exec['Manual delay to let AEM ready']],
  }

  class { '::aem_resources::create_system_users':
    require => [Aem_aem['Wait until login page is ready']],
  }

  aem_package { 'Install AEM Healthcheck Content Package':
    ensure    => present,
    name      => 'aem-healthcheck-content',
    group     => 'shinesolutions',
    version   => $aem_healthcheck_version,
    path      => "${aem_base}/aem",
    replicate => false,
    activate  => false,
    force     => true,
    require   => [Exec['Manual delay to let AEM ready']],
  }

  exec { "rm -f ${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip":
    cwd     => $tmp_dir,
    path    => ['/bin','/sbin','/usr/bin','/usr/sbin'],
    require => Aem_package['Install AEM Healthcheck Content Package'],
  }

  # Ensure login page is still ready after all provisioning steps and before stopping AEM.
  aem_aem { 'Ensure login page is ready':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 30,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
    require                    => [
      Class['aem_resources::author_remove_default_agents'],
      Class['aem_resources::create_system_users'],
      File["${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip"],
    ],
  }
}
