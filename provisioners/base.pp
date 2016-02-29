package { 'wget':
  ensure   => 'installed',
  provider => 'yum',
}

file { "${app_dir}":
  ensure => 'directory',
  owner  => "${aws_user}",
  group  => "${aws_group}",
  mode   => '0775',
}
