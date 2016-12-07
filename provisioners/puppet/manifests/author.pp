class author (
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

  file { "${app_dir}/aem/author":
    ensure  => directory,
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => File["${app_dir}/aem"],
  }

  wget::fetch { $aem_license_source:
    destination => "${app_dir}/aem/author/license.properties",
    timeout     => 0,
    verbose     => false,
    require     => File["${app_dir}/aem/author"],
  } ->
  file { "${app_dir}/aem/author/license.properties":
    ensure => file,
    mode   => '0440',
    owner  => 'aem',
    group  => 'aem',
  }

  wget::fetch { $aem_quickstart_source:
    destination => "${app_dir}/aem/author/aem-author-4502.jar",
    timeout     => 0,
    verbose     => false,
    require     => File["${app_dir}/aem/author"],
  } ->
  file { "${app_dir}/aem/author/aem-author-4502.jar":
    ensure => file,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  aem::instance { 'aem' :
    source         => "${app_dir}/aem/author/aem-author-4502.jar",
    home           => "${app_dir}/aem/author",
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
