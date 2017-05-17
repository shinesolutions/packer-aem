File {
  backup => false,
}

class httpd (
  $tmp_dir,
) {

  stage { 'test':
    require => Stage['main']
  }
  stage { 'shutdown':
    require => Stage['test'],
  }

  class { 'apache': }

  class { 'serverspec':
    stage             => 'test',
    component         => 'httpd',
    staging_directory => "${tmp_dir}/packer-puppet-masterless-httpd",
    tries             => 15,
    try_sleep         => 3,
  }

  class { 'httpd_shutdown':
    stage => 'shutdown',
  }
}

class httpd_shutdown {

  exec { 'service httpd stop':
    cwd  => "${httpd::tmp_dir}",
    path => ['/usr/bin', '/usr/sbin'],
  }

}

include httpd
