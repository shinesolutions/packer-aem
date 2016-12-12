class author (
  $aem_quickstart_source,
  $aem_license_source
){

  stage { 'test':
    require => Stage['main']
  }

  file { '/opt/aem':
    ensure => directory,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  file { '/opt/aem/author':
    ensure  => directory,
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => File['/opt/aem'],
  }

  wget::fetch { $aem_license_source:
    destination => '/opt/aem/author/license.properties',
    timeout     => 0,
    verbose     => false,
    require     => File['/opt/aem/author'],
  } ->
  file { '/opt/aem/author/license.properties':
    ensure => file,
    mode   => '0440',
    owner  => 'aem',
    group  => 'aem',
  }

  wget::fetch { $aem_quickstart_source:
    destination => '/opt/aem/author/aem-author-4502.jar',
    timeout     => 0,
    verbose     => false,
    require     => File['/opt/aem/author'],
  } ->
  file { '/opt/aem/author/aem-author-4502.jar':
    ensure => file,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  aem::instance { 'aem' :
    source         => '/opt/aem/author/aem-author-4502.jar',
    home           => '/opt/aem/author',
    type           => 'author',
    port           => 4502,
    sample_content => false,
    jvm_mem_opts   => '-Xmx4096m',
    jvm_opts       => '-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime -XX:+HeapDumpOnOutOfMemoryError',
  }

  class { 'serverspec':
    stage     => 'test',
    component => 'author',
    tries     => 5,
    try_sleep => 3,
  }

}

include author
