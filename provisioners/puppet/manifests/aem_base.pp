class aem_base (
  $packer_user,
  $packer_group,
  $aem_healthcheck_version,
  $aem_quickstart_source = 'file:///tmp/cq-quickstart.jar',
  $aem_base = '/opt'
){

  stage { 'test':
    require => Stage['main']
  }

  file { "${aem_base}/aem":
    ensure => directory,
    mode   => '0775',
    owner  => $packer_user,
    group  => $packer_group,
  }

  # Move the cq-quickstart jar into aem directory
  file { "${aem_base}/aem/cq-quickstart.jar":
    ensure  => file,
    source  => "${aem_quickstart_source}",
    mode    => '0775',
    owner   => $packer_user,
    group   => $packer_group,
    require => File["${aem_base}/aem"],
  }

  # Download Healthcheck Content Package and move into into aem directory
  file { '/tmp/aem-healthcheck-content':
    ensure => directory,
    mode   => '0775',
    owner  => $packer_user,
    group  => $packer_group,
  } ->
  file { "${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip":
    ensure  => file,
    source  => "http://central.maven.org/maven2/com/shinesolutions/aem-healthcheck-content/${aem_healthcheck_version}/aem-healthcheck-content-${aem_healthcheck_version}.zip",
    mode    => '0664',
    owner   => $packer_user,
    group   => $packer_group,
    require => File["${aem_base}/aem"],
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
    stage     => 'test',
    component => 'aem_base',
    tries     => 5,
    try_sleep => 3,
  }

}

include aem_base
