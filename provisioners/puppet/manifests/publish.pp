class publish (
  $packer_user,
  $packer_group,
  $aem_quickstart_source = '/opt/aem/cq-quickstart.jar',
  $aem_license_source = 'file:///tmp/license.properties',
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

  file { "${aem_base}/aem/publish/license.properties":
    ensure  => file,
    source  => "${aem_license_source}",
    mode    => '0440',
    owner   => 'aem',
    group   => 'aem',
    require => File["${aem_base}/aem/publish"],
  }

  file { "${aem_base}/aem/publish/aem-publish-${aem_port}.jar":
    ensure  => file,
    source  => "${aem_quickstart_source}",
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => File["${aem_base}/aem/publish"],
  }

  file { "${aem_quickstart_source}":
    ensure  => absent,
    require => File["${aem_base}/aem/publish/aem-publish-${aem_port}.jar"],
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

  aem_package { 'Install AEM Healthcheck Content Package':
    ensure    => present,
    name      => 'aem-healthcheck-content',
    group     => 'shinesolutions',
    version   => '1.2',
    path      => "${aem_base}/aem",
    replicate => false,
    activate  => false,
    force     => true,
    require   => [Aem_aem['Wait until login page is ready']],
  }

  file { "${aem_base}/aem/aem-healthcheck-content-1.2.zip":
    ensure  => absent,
    require => Aem_package['Install AEM Healthcheck Content Package'],
  }

  class { 'serverspec':
    stage             => 'test',
    component         => 'publish',
    tries             => 5,
    try_sleep         => 3,
  }

}

include publish
