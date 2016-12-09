class base (
  $app_dir,
  $aws_user,
  $aws_group
){

  stage { 'test':
    require => Stage['main']
  }

  file { $app_dir:
    ensure => directory,
    owner  => $aws_user,
    group  => $aws_group,
    mode   => '0775',
  }

  class { 'timezone': }

  # issue with selinux stopping aem:dispatcher to start. https://github.com/bstopp/puppet-aem/issues/73
  if $::osfamily == 'redhat' {
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

}

include base
