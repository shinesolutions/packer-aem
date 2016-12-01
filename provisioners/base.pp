class base (
  $app_dir,
  $aws_user,
  $aws_group
){

  file { $app_dir:
    ensure => 'directory',
    owner  => $aws_user,
    group  => $aws_group,
    mode   => '0775',
  }

}

include base
