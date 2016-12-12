class publish (
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

  file { '/opt/aem/publish':
    ensure  => directory,
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => File['/opt/aem'],
  }

  wget::fetch { $aem_license_source:
    destination => '/opt/aem/publish/license.properties',
    timeout     => 0,
    verbose     => false,
    require     => File['/opt/aem/publish'],
  } ->
  file { '/opt/aem/publish/license.properties':
    ensure => file,
    mode   => '0440',
    owner  => 'aem',
    group  => 'aem',
  }

  wget::fetch { $aem_quickstart_source:
    destination => '/opt/aem/publish/aem-publish-4503.jar',
    timeout     => 0,
    verbose     => false,
    require     => File['/opt/aem/publish'],
  } ->
  file { '/opt/aem/publish/aem-publish-4503.jar':
    ensure => file,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  aem::instance { 'aem' :
    source         => '/opt/aem/publish/aem-publish-4503.jar',
    home           => '/opt/aem/publish',
    type           => 'publish',
    port           => 4503,
    sample_content => false,
    jvm_mem_opts   => '-Xmx4096m',
    jvm_opts       => '-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime -XX:+HeapDumpOnOutOfMemoryError',
  }

  class { 'serverspec':
    stage     => 'test',
    component => 'publish',
    tries     => 5,
    try_sleep => 3,
  }

}

include publish
