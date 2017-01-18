class author (
  $aem_quickstart_source,
  $aem_license_source,
  $packer_user,
  $packer_group,
  $aem_base = '/opt',
  $aem_jvm_mem_opts = '-Xmx4096m',
  $aem_port = '4502',
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

  file { "${aem_base}/aem/author":
    ensure  => directory,
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => File["${aem_base}/aem"],
  }

  wget::fetch { $aem_license_source:
    destination => "${aem_base}/aem/author/license.properties",
    timeout     => 0,
    verbose     => false,
    require     => File["${aem_base}/aem/author"],
  } ->
  file { "${aem_base}/aem/author/license.properties":
    ensure => file,
    mode   => '0440',
    owner  => 'aem',
    group  => 'aem',
  }

  wget::fetch { $aem_quickstart_source:
    destination => "${aem_base}/aem/author/aem-author-${aem_port}.jar",
    timeout     => 0,
    verbose     => false,
    require     => File["${aem_base}/aem/author"],
  } ->
  file { "${aem_base}/aem/author/aem-author-${aem_port}.jar":
    ensure => file,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  aem::instance { 'aem' :
    source         => "${aem_base}/aem/author/aem-author-${aem_port}.jar",
    home           => "${aem_base}/aem/author",
    type           => 'author',
    port           => $aem_port,
    sample_content => $aem_sample_content,
    jvm_mem_opts   => $aem_jvm_mem_opts,
    jvm_opts       => '-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime -XX:+HeapDumpOnOutOfMemoryError',
  }

  file { '/etc/puppetlabs/puppet/aem.yaml':
    ensure  => file,
    content => epp('/tmp/templates/aem.yaml.epp', {'port' => $aem_port}),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  # Confirm AEM Starts up and the login page is ready.
  aem_aem { 'Wait until login page is ready':
    ensure  => login_page_is_ready,
    require => [Aem::Instance['aem'], File['/etc/puppetlabs/puppet/aem.yaml']],
  }

  file { '/tmp/aem-healthcheck-content':
    ensure => directory,
    mode   => '0775',
    owner  => $packer_user,
    group  => $packer_group,
  } ->
  wget::fetch { 'https://github.com/shinesolutions/aem-healthcheck/releases/download/v1.2/aem-healthcheck-content-1.2.zip':
    destination => '/tmp/aem-healthcheck-content/aem-healthcheck-content-1.2.zip',
    timeout     => 0,
    verbose     => false,
  } ->
  file { '/tmp/aem-healthcheck-content/aem-healthcheck-content-1.2.zip':
    ensure => file,
    owner  => $packer_user,
    group  => $packer_group,
  }

  aem_package { 'Install AEM Healthcheck Content Package':
    ensure    => present,
    name      => 'aem-healthcheck-content',
    group     => 'shinesolutions',
    version   => '1.2',
    path      => '/tmp/aem-healthcheck-content/',
    replicate => false,
    activate  => false,
    force     => true,
    require   => [File['/tmp/aem-healthcheck-content/aem-healthcheck-content-1.2.zip'], Aem_aem['Wait until login page is ready']],
  }

  class { 'serverspec':
    stage             => 'test',
    component         => 'author',
    staging_directory => '/tmp/packer-puppet-masterless-1',
    tries             => 5,
    try_sleep         => 3,
  }

}

include author
