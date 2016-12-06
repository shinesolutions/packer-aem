include jdk_oracle

stage { 'test':
  require => Stage['main']
}

class { 'serverspec':
  stage     => 'test',
  component => 'java',
  tries     => 5,
  try_sleep => 3,
}
