class dispatcher (
  $aem_dispatcher_source,
  $filename,
  $tmp_dir,
  $module_filename,
  $packer_user,
  $packer_group
){

  stage { 'test':
    require => Stage['main']
  }
  stage { 'shutdown':
    require => Stage['test'],
  }

  file { "${tmp_dir}":
    ensure => directory,
    owner  => $packer_user,
    group  => $packer_group,
    mode   => '0775',
  }

  class { 'apache':
    package_ensure => installed,
  }

  archive { $filename:
    path         => "${tmp_dir}/${filename}",
    extract      => true,
    extract_path => "${tmp_dir}",
    source       => $aem_dispatcher_source,
    cleanup      => true,
    require      => File["${tmp_dir}"],
    user         => $packer_user,
    group        => $packer_group,
  }

  class { 'aem::dispatcher' :
    module_file => "${tmp_dir}/${module_filename}",
  } ->
  exec { 'httpd -k graceful':
    cwd  => "${tmp_dir}",
    path => ['/sbin','/usr/sbin'],
  }

  class { 'serverspec':
    stage             => 'test',
    component         => 'dispatcher',
    staging_directory => "${tmp_dir}/packer-puppet-masterless-dispatcher",
    tries             => 15,
    try_sleep         => 3,
  }

  class { 'dispatcher_shutdown':
    stage => 'shutdown',
  }

}

class dispatcher_shutdown {

  exec { 'service httpd stop':
    cwd  => "${dispatcher::tmp_dir}",
    path => ['/sbin/','/usr/bin', '/usr/sbin'],
  }

}

include dispatcher
