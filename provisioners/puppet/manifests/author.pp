class author (
  $tmp_dir,
  $aem_quickstart_source,
  $aem_license_source,
  $aem_cert_source,
  $aem_key_source,
  $aem_keystore_password,
  $aem_artifacts_base,
  $aem_healthcheck_version,
  $aem_repo_mount_point,
  $aem_base           = '/opt',
  $aem_jvm_mem_opts   = '-Xss4m -Xmx8192m',
  $aem_port           = '4502',
  $aem_sample_content = false,
) {

  stage { 'test':
    require => Stage['main']
  }
  stage { 'shutdown':
    require => Stage['test'],
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

  archive { "${aem_base}/aem/author/aem-author-${aem_port}.jar":
    ensure  => present,
    source  => $aem_quickstart_source,
    cleanup => false,
    require => File["${aem_base}/aem/author"],
  } -> file { "${aem_base}/aem/author/aem-author-${aem_port}.jar":
    ensure => file,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  # Set up configuration file for puppet-aem-resources.
  file { '/etc/puppetlabs/puppet/aem.yaml':
    ensure  => file,
    content => epp("${tmp_dir}/templates/aem.yaml.epp", { 'port' => $aem_port }),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  archive { "${aem_base}/aem/author/license.properties":
    ensure  => present,
    source  => "${aem_license_source}",
    cleanup => false,
    require => File["${aem_base}/aem/author"],
  } -> file { "${aem_base}/aem/author/license.properties":
    ensure => file,
    mode   => '0440',
    owner  => 'aem',
    group  => 'aem',
  }

  # Install AEM Health Check using aem::crx::package file type
  # which will place the artifact in AEM install directory
  # and it will be installed when AEM starts up.
  archive { "${tmp_dir}/aem-healthcheck-content-${aem_healthcheck_version}.zip":
    ensure => present,
    source => "http://central.maven.org/maven2/com/shinesolutions/aem-healthcheck-content/${aem_healthcheck_version}/aem-healthcheck-content-${aem_healthcheck_version}.zip",
  } -> aem::crx::package { 'aem-healthcheck' :
    ensure => present,
    type   => 'file',
    home   => "${aem_base}/aem/author",
    source => "${tmp_dir}/aem-healthcheck-content-${aem_healthcheck_version}.zip",
    user   => 'aem',
    group  => 'aem',
  }

  aem::instance { 'aem':
    source         => "${aem_base}/aem/author/aem-author-${aem_port}.jar",
    home           => "${aem_base}/aem/author",
    type           => 'author',
    port           => $aem_port,
    sample_content => $aem_sample_content,
    jvm_mem_opts   => $aem_jvm_mem_opts,
    jvm_opts       => '-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime -XX:+HeapDumpOnOutOfMemoryError -Dcom.sun.management.jmxremote.port=8463 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false',
    status         => 'running',
  } -> exec { 'Wait AEM post initial installation':
    command => 'sleep 120',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> aem_aem { 'Wait until login page is ready':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> aem_aem { 'Wait until aem health check is ok':
    ensure                     => aem_health_check_is_ok,
    tags                       => 'deep',
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> archive { "${tmp_dir}/cq-6.2.0-hotfix-11490-1.2.zip":
    ensure  => present,
    source  => "${aem_artifacts_base}/cq-6.2.0-hotfix-11490-1.2.zip",
    cleanup => false,
  } -> aem_package { 'Install hotfix 11490':
    ensure    => present,
    name      => 'cq-6.2.0-hotfix-11490',
    group     => 'adobe/cq620/hotfix',
    version   => '1.2',
    path      => "${tmp_dir}",
    replicate => false,
    activate  => false,
    force     => true,
  } -> exec { 'Wait AEM post hotfix 11490 install':
    command => 'sleep 120',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> aem_aem { 'Wait until login page is ready post hotfix 11490 install':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> aem_aem { 'Wait until aem health check is ok post hotfix 11490 install':
    ensure                     => aem_health_check_is_ok,
    tags                       => 'deep',
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> archive { "${tmp_dir}/cq-6.2.0-hotfix-12785-7.0.zip":
    ensure  => present,
    source  => "${aem_artifacts_base}/cq-6.2.0-hotfix-12785-7.0.zip",
    cleanup => false,
  } -> aem_package { 'Install hotfix 12785':
    ensure    => present,
    name      => 'cq-6.2.0-hotfix-12785',
    group     => 'adobe/cq620/hotfix',
    version   => '7.0',
    path      => "${tmp_dir}",
    replicate => false,
    activate  => false,
    force     => true,
  } -> exec { 'Wait AEM post hotfix 12785 install':
    command => 'sleep 120',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> aem_aem { 'Wait until login page is ready post hotfix 12785 install':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> aem_aem { 'Wait until aem health check is ok post hotfix 12785 install':
    ensure                     => aem_health_check_is_ok,
    tags                       => 'deep',
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> exec { 'Restart AEM post hotfix 12785 install':
    command => 'service aem-aem restart',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> exec { 'Wait AEM post hotfix 12785 restart':
    command => 'sleep 120',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> aem_aem { 'Wait until login page is ready post hotfix 12785 restart':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 120,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> aem_aem { 'Wait until aem health check is ok post hotfix 12785 restart':
    ensure                     => aem_health_check_is_ok,
    tags                       => 'deep',
    retries_max_tries          => 120,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> archive { "${tmp_dir}/aem-service-pkg-6.2.SP1.zip":
    ensure  => present,
    source  => "${aem_artifacts_base}/AEM-6.2-Service-Pack-1-6.2.SP1.zip",
    cleanup => false,
  } -> aem_package { 'Install Service Pack 1':
    ensure                     => present,
    name                       => 'aem-service-pkg',
    group                      => 'adobe/cq620/servicepack',
    version                    => '6.2.SP1',
    path                       => "${tmp_dir}",
    replicate                  => false,
    activate                   => false,
    force                      => true,
    retries_max_tries          => 120,
    retries_base_sleep_seconds => 10,
    retries_max_sleep_seconds  => 10,
  } -> exec { 'Wait AEM post Service Pack 1 install':
    command => 'sleep 120',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> aem_aem { 'Wait until login page is ready post Service Pack 1 install':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> aem_aem { 'Wait until aem health check is ok post Service Pack 1 install':
    ensure                     => aem_health_check_is_ok,
    tags                       => 'deep',
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> archive { "${tmp_dir}/cq-6.2.0-sp1-cfp-2.0.zip":
    ensure  => present,
    source  => "${aem_artifacts_base}/AEM-6.2-SP1-CFP2-2.0.zip",
    cleanup => false,
  } -> aem_package { 'Install Service Pack 1 Cumulative Fix Pack 2':
    ensure                     => present,
    name                       => 'cq-6.2.0-sp1-cfp',
    group                      => 'adobe/cq620/cumulativefixpack',
    version                    => '2.0',
    path                       => "${tmp_dir}",
    replicate                  => false,
    activate                   => false,
    force                      => true,
    retries_max_tries          => 120,
    retries_base_sleep_seconds => 10,
    retries_max_sleep_seconds  => 10,
  } -> exec { 'Wait AEM post Service Pack 1 Cumulative Fix Pack 2 install':
    command => 'sleep 120',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> aem_aem { 'Wait until login page is ready post Service Pack 1 Cumulative Fix Pack 2 install':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> aem_aem { 'Wait until aem health check is ok post Service Pack 1 Cumulative Fix Pack 2 install':
    ensure                     => aem_health_check_is_ok,
    tags                       => 'deep',
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> archive { "${tmp_dir}/cq-6.2.0-hotfix-15607-1.0.zip":
    ensure  => present,
    source  => "${aem_artifacts_base}/cq-6.2.0-hotfix-15607-1.0.zip",
    cleanup => false,
  } -> aem_package { 'Install hotfix 15607':
    ensure    => present,
    name      => 'cq-6.2.0-hotfix-15607',
    group     => 'adobe/cq620/hotfix',
    version   => '1.0',
    path      => "${tmp_dir}",
    replicate => false,
    activate  => false,
    force     => true,
  } -> exec { 'Wait AEM post hotfix 15607 install':
    command => 'sleep 120',
    cwd     => "${tmp_dir}",
    path    => ['/usr/bin', '/usr/sbin'],
  } -> aem_aem { 'Wait until login page is ready post hotfix 15607 install':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> aem_aem { 'Wait until aem health check is ok post hotfix 15607 install':
    ensure                     => aem_health_check_is_ok,
    tags                       => 'deep',
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  }

  # Create system users and configure their usernames for password reset during provisioning
  class { 'aem_resources::create_system_users':
    orchestrator_password => 'orchestrator',
    replicator_password   => 'replicator',
    deployer_password     => 'deployer',
    exporter_password     => 'exporter',
    importer_password     => 'importer',
    require               => Aem_aem['Wait until aem health check is ok post hotfix 15607 install'],
  } -> aem_node { 'Create AEM Password Reset Activator config node':
    ensure => present,
    name   => 'com.shinesolutions.aem.passwordreset.Activator',
    path   => '/apps/system/config.author',
    type   => 'sling:OsgiConfig',
  } -> aem_config_property { 'Configure system usernames for AEM Password Reset Activator to process':
    ensure           => present,
    name             => 'pwdreset.authorizables',
    type             => 'String[]',
    value            => ['admin', 'orchestrator', 'replicator', 'deployer', 'exporter', 'importer'],
    run_mode         => 'author',
    config_node_name => 'com.shinesolutions.aem.passwordreset.Activator',
  }

  aem_node { 'Create AEM Health Check Servlet config node':
    ensure  => present,
    name    => 'com.shinesolutions.healthcheck.hc.impl.ActiveBundleHealthCheck',
    path    => '/apps/system/config.author',
    type    => 'sling:OsgiConfig',
    require => Aem_aem['Wait until login page is ready post Service Pack 1 Cumulative Fix Pack 2 install'],
  } -> aem_config_property { 'Configure AEM Health Check Servlet ignored bundles':
    ensure           => present,
    name             => 'bundles.ignored',
    type             => 'String[]',
    value            => ['org.apache.sling.jcr.webdav', 'org.apache.sling.jcr.davex'],
    run_mode         => 'author',
    config_node_name => 'com.shinesolutions.healthcheck.hc.impl.ActiveBundleHealthCheck',
  }

  class { 'aem_resources::author_remove_default_agents':
    require => [Aem_aem['Wait until login page is ready post Service Pack 1 Cumulative Fix Pack 2 install']],
  }

  # Enable SSL support on AEM
  archive { "${tmp_dir}/aem.key":
    ensure => present,
    source => $aem_key_source,
  } -> archive { "${tmp_dir}/aem.cert":
    ensure => present,
    source => $aem_cert_source,
  } -> file { "${aem_base}/aem/author/crx-quickstart/ssl/":
    ensure  => directory,
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => [
      Aem_config_property['Configure system usernames for AEM Password Reset Activator to process'],
      Aem_config_property['Configure AEM Health Check Servlet ignored bundles'],
      Class['aem_resources::author_remove_default_agents'],
    ],
  } -> java_ks { 'Set up keystore':
    ensure       => latest,
    name         => 'cqse',
    certificate  => "${tmp_dir}/aem.cert",
    target       => "${aem_base}/aem/author/crx-quickstart/ssl/aem.ks",
    private_key  => "${tmp_dir}/aem.key",
    password     => $aem_keystore_password,
    trustcacerts => true,
  } -> class { 'aem_resources::author_publish_enable_ssl':
    run_mode            => 'author',
    port                => 5433,
    keystore            => "${aem_base}/aem/author/crx-quickstart/ssl/aem.ks",
    keystore_password   => $aem_keystore_password,
    keystore_key_alias  => 'cqse',
    truststore          => '/usr/java/default/jre/lib/security/cacerts',
    truststore_password => 'changeit',
  }

  collectd::plugin::genericjmx::connection { 'java_app':
    host        => $::fqdn,
    service_url => 'service:jmx:rmi:///jndi/rmi://localhost:8463/jmxrmi',
    collect     => [ 'memory-heap', 'memory-nonheap', 'garbage_collector', 'memory-permgen' ],
  }

  # Ensure login page is still ready after all provisioning steps and before stopping AEM.
  aem_aem { 'Ensure aem health check is ok':
    ensure                     => aem_health_check_is_ok,
    tags                       => 'deep',
    retries_max_tries          => 30,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
    require                    => Class['aem_resources::author_publish_enable_ssl'],
  } -> aem_aem { 'Ensure login page is ready':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 30,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } -> class { 'serverspec':
    stage             => 'test',
    component         => 'author',
    staging_directory => "${tmp_dir}/packer-puppet-masterless-author",
    tries             => 5,
    try_sleep         => 3,
  }

  class { 'author_shutdown':
    stage => 'shutdown',
  }

}

class author_shutdown {

  exec { 'service aem-aem stop':
    cwd  => "${author::tmp_dir}",
    path => ['/usr/bin', '/usr/sbin'],
  } -> exec { "rm -f ${aem_base}/aem/author/crx-quickstart/install/aem-healthcheck-content-${author::aem_healthcheck_version}.zip":
    path => ['/usr/bin', '/usr/sbin'],
  }

  file { "${author::aem_repo_mount_point}":
    ensure => directory,
    mode   => '0755',
    owner  => 'aem',
    group  => 'aem',
  } -> exec { "mv ${author::aem_base}/aem/author/crx-quickstart/repository/* ${author::aem_repo_mount_point}/":
    cwd  => "${author::tmp_dir}",
    path => '/usr/bin',
  } -> file { "${author::aem_base}/aem/author/crx-quickstart/repository/":
    ensure => 'link',
    owner  => 'aem',
    group  => 'aem',
    force  => true,
    target => "${author::aem_repo_mount_point}",
  }
}

include author
