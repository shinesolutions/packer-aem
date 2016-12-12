stage { 'test':
  require => Stage['main']
}

class { 'timezone': }

if $::osfamily == 'redhat' {

  #TODO: if disable selinux is true
  # issue with selinux stopping aem:dispatcher to start. https://github.com/bstopp/puppet-aem/issues/73
  class { 'selinux':
    mode => 'disabled',
  }

}

class { 'serverspec':
  stage     => 'test',
  component => 'base',
  tries     => 5,
  try_sleep => 3,
}
