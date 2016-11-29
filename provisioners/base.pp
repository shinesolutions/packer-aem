package { 'wget':
  ensure   => 'installed',
  provider => 'yum',
}

file { "/app":
  ensure => 'directory',
  owner  => "ec2-user",
  group  => "ec2-user",
  mode   => '0775',
}
