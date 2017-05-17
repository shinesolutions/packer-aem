File {
  backup => false,
}

class dispatcher (
  $aem_dispatcher_source,
  $aem_cert_source,
  $aem_key_source,
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

  # Prepare AEM unified dispatcher certificate
  archive { "${tmp_dir}/aem.cert":
    ensure => present,
    source => "${aem_cert_source}",
  }
  archive { "${tmp_dir}/aem.key":
    ensure => present,
    source => "${aem_key_source}",
  }
  file { '/etc/ssl/aem.unified-dispatcher.cert':
    ensure => absent,
  }
  exec { "cat ${tmp_dir}/aem.key >> /etc/ssl/aem.unified-dispatcher.cert":
    cwd  => "${tmp_dir}",
    path => ['/usr/bin'],
  }
  exec { "cat ${tmp_dir}/aem.cert >> /etc/ssl/aem.unified-dispatcher.cert":
    cwd  => "${tmp_dir}",
    path => ['/usr/bin'],
  }

  class { 'apache':
    package_ensure => installed,
  }

  class { 'apache::mod::headers':
  }

  class { 'apache::mod::ssl':
  }

  file { "${tmp_dir}":
    ensure => directory,
    owner  => $packer_user,
    group  => $packer_group,
    mode   => '0775',
  } -> archive { $filename:
    path         => "${tmp_dir}/${filename}",
    extract      => true,
    extract_path => "${tmp_dir}",
    source       => $aem_dispatcher_source,
    cleanup      => true,
    require      => File["${tmp_dir}"],
    user         => $packer_user,
    group        => $packer_group,
  } -> class { 'aem::dispatcher' :
    module_file => "${tmp_dir}/${module_filename}",
  } -> file { '/var/www/html':
    # Set the Docroot owner and group to apache
    # https://docs.adobe.com/docs/en/dispatcher/disp-install.html#Apache Web Server - Configure Apache Web Server for Dispatcher
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
  } -> exec { 'httpd -k graceful':
    cwd  => "${tmp_dir}",
    path => ['/sbin'],
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
    path => ['/usr/bin', '/usr/sbin'],
  }

}

include dispatcher
