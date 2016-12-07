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

  package { 'ruby':
    ensure  => installed,
  }

  class { 'serverspec':
    stage     => 'test',
    component => 'base',
    tries     => 5,
    try_sleep => 3,
  }

}

include base
