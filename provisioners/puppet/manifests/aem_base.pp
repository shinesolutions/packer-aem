class aem_base (
  $aem_healthcheck_version,
  $aem_base = '/opt'
) {

  stage { 'test':
    require => Stage['main']
  }

  file { "${aem_base}/aem":
    ensure => directory,
    mode   => '0775',
  }

  # Retrieve Healthcheck Content Package and move into aem directory
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

  package { 'nokogiri':
    ensure   => '1.6.8.1',
    provider => 'puppet_gem',
  } ->
    package { 'ruby_aem':
      ensure   => '1.0.6',
      provider => 'puppet_gem',
    }

  class { 'serverspec':
    stage             => 'test',
    component         => 'aem_base',
    staging_directory => '/tmp/packer-puppet-masterless-0',
    tries             => 5,
    try_sleep         => 3,
  }

}

include aem_base
