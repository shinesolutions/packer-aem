class aem_base (
  $packer_user,
  $packer_group,
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
    owner  => $packer_user,
    group  => $packer_group,
    require => File["${aem_base}/aem"],
  }

  # Download Healthcheck Content Package and move into into aem directory
  file { '/tmp/aem-healthcheck-content':
    ensure => directory,
    mode   => '0775',
    owner  => $packer_user,
    group  => $packer_group,
  } ->
  wget::fetch { 'https://github.com/shinesolutions/aem-healthcheck/releases/download/v1.2/aem-healthcheck-content-1.2.zip':
    destination => '/tmp/aem-healthcheck-content/aem-healthcheck-content-1.2.zip',
    timeout     => 0,
    verbose     => false,
  } ->
  file { "${aem_base}/aem/aem-healthcheck-content-1.2.zip":
    ensure  => file,
    source  => '/tmp/aem-healthcheck-content/aem-healthcheck-content-1.2.zip',
    mode    => '0664',
    owner  => $packer_user,
    group  => $packer_group,
    require => File["${aem_base}/aem"],
  }

  class { 'serverspec':
    stage     => 'test',
    component => 'aem_base',
    tries     => 5,
    try_sleep => 3,
  }

}

include aem_base
