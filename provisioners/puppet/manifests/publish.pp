class publish (
  $aem_quickstart_source,
  $aem_license_source,
  $aem_base = '/opt',
  $aem_jvm_mem_opts = '-Xmx4096m',
  $aem_port = '4503',
  $aem_sample_content = false
){

  stage { 'test':
    require => Stage['main']
  }

  file { "${aem_base}/aem":
    ensure => directory,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  file { "${aem_base}/aem/publish":
    ensure  => directory,
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => File["${aem_base}/aem"],
  }

  wget::fetch { $aem_license_source:
    destination => "${aem_base}/aem/publish/license.properties",
    timeout     => 0,
    verbose     => false,
    require     => File["${aem_base}/aem/publish"],
  } ->
  file { "${aem_base}/aem/publish/license.properties":
    ensure => file,
    mode   => '0440',
    owner  => 'aem',
    group  => 'aem',
  }

  wget::fetch { $aem_quickstart_source:
    destination => "${aem_base}/aem/publish/aem-publish-${aem_port}.jar",
    timeout     => 0,
    verbose     => false,
    require     => File["${aem_base}/aem/publish"],
  } ->
  file { "${aem_base}/aem/publish/aem-publish-${aem_port}.jar":
    ensure => file,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  aem::instance { 'aem' :
    source         => "${aem_base}/aem/publish/aem-publish-${aem_port}.jar",
    home           => "${aem_base}/aem/publish",
    type           => 'publish',
    port           => $aem_port,
    sample_content => $aem_sample_content,
    jvm_mem_opts   => $aem_jvm_mem_opts,
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
