class { 'apache': }

stage { 'test':
  require => Stage['main']
}

class { 'serverspec':
  stage     => 'test',
  component => 'httpd',
  tries     => 15,
  try_sleep => 3,
}
