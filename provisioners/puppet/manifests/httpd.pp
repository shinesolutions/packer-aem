stage { 'test':
  require => Stage['main']
}
stage { 'shutdown':
  require => Stage['test'],
}

class { 'apache': }

class { 'serverspec':
  stage     => 'test',
  component => 'httpd',
  tries     => 15,
  try_sleep => 3,
}

class { 'httpd_shutdown':
  stage => 'shutdown',
}

class httpd_shutdown {

  exec { 'service httpd stop':
    cwd  => '/tmp',
    path => ['/usr/bin', '/usr/sbin'],
  }

}
