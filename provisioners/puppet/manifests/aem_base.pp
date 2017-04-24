class aem_base (
  $tmp_dir,
  $aem_repo_device,
  $aem_healthcheck_version,
  $aem_repo_mount_point,
  $aem_base = '/opt'
) {

  stage { 'test':
    require => Stage['main']
  }

  exec { 'Prepare device for AEM repository':
    command => "mkfs -t ext4 ${aem_repo_device}",
    path    => ['/sbin'],
  } -> file { "${aem_repo_mount_point}":
    ensure => directory,
    mode   => '0755',
  } -> mount { "${aem_repo_mount_point}":
    ensure   => mounted,
    device   => $aem_repo_device,
    fstype   => 'ext4',
    options  => 'nofail,defaults,noatime',
    remounts => false,
    atboot   => false,
  }

  file { "${aem_base}/aem":
    ensure => directory,
    mode   => '0775',
  }

  package { 'nokogiri':
    ensure   => '1.6.8.1',
    provider => 'puppet_gem',
  } -> package { 'ruby_aem':
    ensure   => '1.0.18',
    provider => 'puppet_gem',
  }

  class { 'serverspec':
    stage             => 'test',
    component         => 'aem_base',
    staging_directory => "${tmp_dir}/packer-puppet-masterless-aem_base",
    tries             => 5,
    try_sleep         => 3,
  }

}

include aem_base
