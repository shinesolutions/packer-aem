class serverspec (
  $component,
  $tries,
  $try_sleep,
  $owner,
  $group,
){

  file { '/tmp/serverspec/':
    ensure => directory,
    mode   => '0775',
    owner  => $owner,
    group  => $group,
  }

  file { '/tmp/serverspec/serverspec.sh' :
    ensure  => present,
    mode    => '0775',
    owner   => $owner,
    group   => $group,
    source  => 'puppet:///modules/serverspec/serverspec.sh',
    require => File['/tmp/serverspec/'],
  }

  package { 'ruby':
    ensure  => installed,
  }

  exec { "/tmp/serverspec/serverspec.sh ${component}":
    path      => ':/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:~/bin',
    tries     => $tries,
    try_sleep => $try_sleep,
    require   => [File['/tmp/serverspec/serverspec.sh'], Package['ruby']],
    user      => $owner,
  }

}
