class publish (
  $aem_quickstart_source,
  $aem_license_source,
  $app_dir
){

  stage { 'test':
    require => Stage['main']
  }

  file { "${app_dir}/aem":
    ensure => directory,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  file { "${app_dir}/aem/publish":
    ensure  => directory,
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => File["${app_dir}/aem"],
  }

  wget::fetch { $aem_license_source:
    destination => "${app_dir}/aem/publish/license.properties",
    timeout     => 0,
    verbose     => false,
    require     => File["${app_dir}/aem/publish"],
  } ->
  file { "${app_dir}/aem/publish/license.properties":
    ensure => file,
    mode   => '0440',
    owner  => 'aem',
    group  => 'aem',
  }

  wget::fetch { $aem_quickstart_source:
    destination => "${app_dir}/aem/publish/aem-publish-4503.jar",
    timeout     => 0,
    verbose     => false,
    require     => File["${app_dir}/aem/publish"],
  } ->
  file { "${app_dir}/aem/publish/aem-publish-4503.jar":
    ensure => file,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  aem::instance { 'aem' :
    source         => "${app_dir}/aem/publish/aem-publish-4503.jar",
    home           => "${app_dir}/aem/publish",
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
