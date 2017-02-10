class serverspec (
  $component,
  $tries,
  $try_sleep,
  $owner,
  $group,
  $tmp_dir = '/tmp/shinesolutions/packer-aem',
  $staging_directory = '/tmp/shinesolutions/packer-aem/packer-puppet-masterless',
  $puppet_bin_dir = '/opt/puppetlabs/puppet/bin'
){

  file { "${tmp_dir}/serverspec/":
    ensure => directory,
    mode   => '0775',
    owner  => $owner,
    group  => $group,
  }

  file { "${tmp_dir}/serverspec/serverspec.sh" :
    ensure  => present,
    mode    => '0775',
    owner   => $owner,
    group   => $group,
    source  => 'puppet:///modules/serverspec/serverspec.sh',
    require => File["${tmp_dir}/serverspec/"],
  }

  exec { "${tmp_dir}/serverspec/serverspec.sh ${component} ${staging_directory}":
    path      => ":${puppet_bin_dir}:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:~/bin",
    tries     => $tries,
    try_sleep => $try_sleep,
    require   => File["${tmp_dir}/serverspec/serverspec.sh"],
    user      => $owner,
  }

}
