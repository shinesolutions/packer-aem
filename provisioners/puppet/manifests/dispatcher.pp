class dispatcher (
  $installation_source,
  $filename,
  $tmp_dir,
  $module_filename,
  $packer_user,
  $packer_group
){

  stage { 'test':
    require => Stage['main']
  }

  file { $tmp_dir:
    ensure => directory,
    owner  => $packer_user,
    group  => $packer_group,
    mode   => '0775',
  }

  class { 'apache':
    package_ensure => installed,
  }

  archive { $filename:
    path         => "/tmp/${filename}",
    extract      => true,
    extract_path => $tmp_dir,
    source       => $installation_source,
    cleanup      => true,
    require      => File[$tmp_dir],
    user         => $packer_user,
    group        => $packer_group,
  }

  class { 'aem::dispatcher' :
    module_file => "${tmp_dir}/${module_filename}",
  }

  class { 'serverspec':
    stage     => 'test',
    component => 'dispatcher',
    tries     => 15,
    try_sleep => 3,
  }

}

include dispatcher
