stage { 'test':
  require => Stage['main']
}

include jdk_oracle

class { 'serverspec':
  stage     => 'test',
  component => 'java',
  tries     => 5,
  try_sleep => 3,
}
