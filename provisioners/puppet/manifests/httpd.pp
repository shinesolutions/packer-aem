stage { 'test':
  require => Stage['main']
}

class { 'apache': }

class { 'serverspec':
  stage     => 'test',
  component => 'httpd',
  tries     => 15,
  try_sleep => 3,
}
