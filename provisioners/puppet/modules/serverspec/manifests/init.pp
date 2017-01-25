class serverspec (
  $component,
  $tries,
  $try_sleep,
  $owner,
  $group,
  $staging_directory = '/tmp/packer-puppet-masterless',
  $puppet_bin_dir = '/opt/puppetlabs/puppet/bin'
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

  exec { "/tmp/serverspec/serverspec.sh ${component} ${staging_directory}":
    path      => ":${puppet_bin_dir}:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:~/bin",
    tries     => $tries,
    try_sleep => $try_sleep,
    require   => File['/tmp/serverspec/serverspec.sh'],
    user      => $owner,
  }

}
