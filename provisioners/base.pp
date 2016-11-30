class base (
  $app_dir,
  $aws_user,
  $aws_group
){

  package { 'wget':
    ensure   => 'installed',
    provider => 'yum',
  }

  file { $app_dir:
    ensure => 'directory',
    owner  => $aws_user,
    group  => $aws_group,
    mode   => '0775',
  }

}

include base
