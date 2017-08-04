# == Class: config::aem
#
#  Shared Resources used by other AEM modules
#
# === Parameters
#
# [*tmp_dir*]
#   A temporary directory used for staging
#
# [*aem_role*]
#   The AEM role to install. Should be 'publish' or 'author'.
#
# [*aem_port*]
#   TCP port AEM will listen on.
#
# [*aem_quickstart_source*]
# [*aem_license_source*]
# [*aem_artifacts_base*]
#   URLs (s3://, http:// or file://) for the AEM jar, license and package
#   files.
#
# [*aem_healthcheck_version*]
#   The version of the AEM healthcheck service to install.
#
# [*aem_base*]
#   Base directory for installing AEM.
#
# [*aem_sample_content*]
#   Boolean that determines whether the AEM sample content should be installed.
#
# [*aem_jvm_mem_opts*]
#   Extra memory options to be passed to the JVM.
#
# [*setup_repository_volume*]
#   Boolean that determines whether a separate volume is formatted and mounted
#   for the AEM repository.
#
# [*repository_volume_device*]
#   The device for format and mount for the AEM repository.
#
# [*repository_volume_mount_point*]
#   The mount point for the AEM repository volume.
#
# [*aem_keystore_path*]
#   The full path to the Java keystore that will store the X.509 certificate
#   and private key to be used by AEM.
#
# [*aem_keystore_password*]
#   The password for the AEM Java keystore.
#
# [*cert_base_url*]
#   Base URL (supported by the puppet-archive module) to download the X.509
#   certificate and private key to be used with Apache.
#
# [*cert_temp_dir*]
#   A temporary directory used to store the X.509 certificate and private key
#   while building the PEM file for Apache.
#
# [*sleep_secs*]
#   Number of seconds to sleep to allow AEM to settle. If installation fails,
#   try turning this up.
#
# [*jvm_opts*]
#   An array of command line options to pass to the JVM when starting AEM.
#
# === Authors
#
# Andy Wang <andy.wang@shinesolutions.com>
# James Sinclair <james.sinclair@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017 Shine Solutions Group, unless otherwise noted.
#

class config::aem (
  $tmp_dir,

  $aem_role,
  $aem_port,
  $aem_quickstart_source,
  $aem_license_source,
  $aem_artifacts_base,
  $aem_healthcheck_version,
  $aem_base           = '/opt',
  $aem_sample_content = false,
  $aem_jvm_mem_opts   = '-Xss4m -Xmx8192m',

  $setup_repository_volume       = false,
  $repository_volume_device      = '/dev/xvdb',
  $repository_volume_mount_point = '/mnt/ebs1',

  $aem_keystore_path = undef,
  $aem_keystore_password = undef,
  $cert_base_url = undef,
  $cert_temp_dir = undef,

  $sleep_secs = 120,

  $jvm_opts = [
    '-XX:+PrintGCDetails',
    '-XX:+PrintGCTimeStamps',
    '-XX:+PrintGCDateStamps',
    '-XX:+PrintTenuringDistribution',
    '-XX:+PrintGCApplicationStoppedTime',
    '-XX:+HeapDumpOnOutOfMemoryError',
  ],
) {

  include ::config::java

  Exec {
    cwd  => '/tmp',
    path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
  }

  Config::Aem_install_package {
    artifacts_base             => $aem_artifacts_base,
    retries_max_tries          => 120,
    retries_base_sleep_seconds => 10,
    retries_max_sleep_seconds  => 10,
  }

  Aem_aem {
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  }

  if $setup_repository_volume {
    exec { 'Prepare device for the AEM repository':
      command => "mkfs -t ext4 ${repository_volume_device}",
    }
    -> file { $repository_volume_mount_point:
      ensure => directory,
      mode   => '0755',
    }
    -> mount { $repository_volume_mount_point:
      ensure   => mounted,
      device   => $repository_volume_device,
      fstype   => 'ext4',
      options  => 'nofail,defaults,noatime',
      remounts => false,
      atboot   => false,
    }
    -> exec { 'Fix repository mount permissions':
      command => "chown aem:aem ${repository_volume_mount_point}",
      require => User['aem'],
    }
  }

  if $::config::base::install_cloudwatchlogs {
    $aem_log_dir = "/opt/aem/${aem_role}/crx-quickstart/logs"
    $aem_apache_datetime_files = [ 'access.log', 'request.log' ]
    $aem_stdout_datetime_files = [ 'stdout.log', 'error.log', 'history.log' ]
    $aem_iso8601_datetime_files = [ 'gc_logs.log' ]
    $aem_unknown_datetime_files = [
      # TODO Get example log files to determine `datetime_format`
      'audit.log', 'auditlog.log', 'upgrade.log',
    ]
    $aem_unknown_datetime_files.each |$file| {
      cloudwatchlogs::log { "${aem_log_dir}/${file}":
        notify          => Service['awslogs'],
      }
    }
    $aem_apache_datetime_files.each |$file| {
      cloudwatchlogs::log { "${aem_log_dir}/${file}":
        datetime_format => '%d/%b/%Y:%H:%M:%S %z',
        notify          => Service['awslogs'],
      }
    }
    $aem_stdout_datetime_files.each |$file| {
      cloudwatchlogs::log { "${aem_log_dir}/${file}":
        datetime_format => '%d.%m.%Y %H:%M:%S.%f',
        notify          => Service['awslogs'],
      }
    }
    $aem_iso8601_datetime_files.each |$file| {
      cloudwatchlogs::log { "${aem_log_dir}/${file}":
        datetime_format => '%Y-%m-%dT%H:%M:%S.%f%z',
        notify          => Service['awslogs'],
      }
    }
  }

  file { [ "${aem_base}/aem", "${aem_base}/aem/${aem_role}"]:
    ensure => directory,
    mode   => '0775',
    owner  => 'aem',
    group  => 'aem',
  }

  # Retrieve the cq-quickstart jar
  archive { "${aem_base}/aem/${aem_role}/aem-${aem_role}-${aem_port}.jar":
    ensure  => present,
    source  => $aem_quickstart_source,
    cleanup => false,
    require => File["${aem_base}/aem/${aem_role}"],
  }
  -> file { "${aem_base}/aem/${aem_role}/aem-${aem_role}-${aem_port}.jar":
    ensure  => file,
    mode    => '0775',
    owner   => 'aem',
    group   => 'aem',
    require => File["${aem_base}/aem/${aem_role}"],
  }

  # Set up configuration file for puppet-aem-resources.
  file { '/etc/puppetlabs/puppet/aem.yaml':
    ensure  => file,
    content => epp('config/aem.yaml.epp', { 'port' => $aem_port }),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  # Retrieve the license file
  archive { "${aem_base}/aem/${aem_role}/license.properties":
    ensure  => present,
    source  => $aem_license_source,
    cleanup => false,
    require => File["${aem_base}/aem/${aem_role}"],
  }
  -> file { "${aem_base}/aem/${aem_role}/license.properties":
    ensure => file,
    mode   => '0440',
    owner  => 'aem',
    group  => 'aem',
  }


  # Install AEM Health Check using aem::crx::package file type which will place
  # the artifact in AEM install directory and it will be installed when AEM
  # starts up.
  archive { "${tmp_dir}/aem-healthcheck-content-${aem_healthcheck_version}.zip":
    ensure => present,
    source => "http://central.maven.org/maven2/com/shinesolutions/aem-healthcheck-content/${aem_healthcheck_version}/aem-healthcheck-content-${aem_healthcheck_version}.zip",
  } -> aem::crx::package { 'aem-healthcheck' :
    ensure => present,
    type   => 'file',
    home   => "${aem_base}/aem/${aem_role}",
    source => "${tmp_dir}/aem-healthcheck-content-${aem_healthcheck_version}.zip",
    user   => 'aem',
    group  => 'aem',
  }

  aem::instance { 'aem':
    source         => "${aem_base}/aem/${aem_role}/aem-${aem_role}-${aem_port}.jar",
    home           => "${aem_base}/aem/${aem_role}",
    type           => $aem_role,
    port           => $aem_port,
    sample_content => $aem_sample_content,
    jvm_mem_opts   => $aem_jvm_mem_opts,
    jvm_opts       => $jvm_opts.join(' '),
    status         => 'running',
  }
  -> exec { 'Manual delay to let AEM become ready':
    command => "sleep ${sleep_secs}",
  }
  # Confirm AEM Starts up and the login page is ready.
  -> aem_aem { 'Wait until login page is ready':
    ensure  => login_page_is_ready,
  }
  -> aem_aem { 'Wait until aem health check is ok':
    ensure => aem_health_check_is_ok,
    tags   => 'deep',
  }
  -> config::aem_install_package { 'cq-6.2.0-hotfix-11490':
    group   => 'adobe/cq620/hotfix',
    version => '1.2',
  }
  -> config::aem_install_package { 'cq-6.2.0-hotfix-12785':
    group                       => 'adobe/cq620/hotfix',
    version                     => '7.0',
    restart                     => true,
    post_install_sleep_secs     => 150,
    post_login_page_ready_sleep => 30,
  }
  -> config::aem_install_package { 'aem-service-pkg':
    file_name => 'AEM-6.2-Service-Pack-1-6.2.SP1.zip',
    group     => 'adobe/cq620/servicepack',
    version   => '6.2.SP1',
  }
  -> config::aem_install_package { 'cq-6.2.0-sp1-cfp':
    file_name               => 'AEM-6.2-SP1-CFP2-3.0.zip',
    group                   => 'adobe/cq620/cumulativefixpack',
    post_install_sleep_secs => 900,
    version                 => '3.0',
  }
  -> config::aem_install_package { 'cq-6.2.0-hotfix-15607':
    group   => 'adobe/cq620/hotfix',
    version => '1.0',
  }

  # Create system users and configure their usernames for password reset during provisioning
  class { '::aem_resources::create_system_users':
    orchestrator_password => 'orchestrator',
    replicator_password   => 'replicator',
    deployer_password     => 'deployer',
    exporter_password     => 'exporter',
    importer_password     => 'importer',
    require               => Config::Aem_install_package['cq-6.2.0-hotfix-15607'],
  }
  -> aem_node { 'Create AEM Password Reset Activator config node':
    ensure => present,
    name   => 'com.shinesolutions.aem.passwordreset.Activator',
    path   => "/apps/system/config.${aem_role}",
    type   => 'sling:OsgiConfig',
  }
  -> aem_config_property { 'Configure system usernames for AEM Password Reset Activator to process':
    ensure           => present,
    name             => 'pwdreset.authorizables',
    type             => 'String[]',
    value            => ['admin', 'orchestrator', 'replicator', 'deployer', 'exporter', 'importer'],
    run_mode         => $aem_role,
    config_node_name => 'com.shinesolutions.aem.passwordreset.Activator',
  }
  -> aem_user { 'Update replication-service user permission':
    # Deny replicate permission for replication-service user to prevent agents from being published
    ensure     => has_permission,
    name       => 'replication-service',
    path       => '/home/users/system/',
    permission => {
      '/etc/replication/agents.author'  => ['replicate:false'],
      '/etc/replication/agents.publish' => ['replicate:false'],
    },
  }

  aem_node { 'Create AEM Health Check Servlet config node':
    ensure  => present,
    name    => 'com.shinesolutions.healthcheck.hc.impl.ActiveBundleHealthCheck',
    path    => "/apps/system/config.${aem_role}",
    type    => 'sling:OsgiConfig',
    require => Config::Aem_install_package['cq-6.2.0-hotfix-15607'],
  }
  -> aem_config_property { 'Configure AEM Health Check Servlet ignored bundles':
    ensure           => present,
    name             => 'bundles.ignored',
    type             => 'String[]',
    run_mode         => $aem_role,
    config_node_name => 'com.shinesolutions.healthcheck.hc.impl.ActiveBundleHealthCheck',
    value            => [
      'org.apache.sling.jcr.webdav',
      'org.apache.sling.jcr.davex',
      'com.adobe.acs.acs-aem-commons-bundle-twitter',
    ],
  }

  $provisioning_steps = [
    Aem_config_property['Configure AEM Health Check Servlet ignored bundles'],
    Aem_user['Update replication-service user permission'],
  ]

  if $aem_role == 'author' {
    class { '::aem_resources::author_remove_default_agents':
      require => Config::Aem_install_package['cq-6.2.0-hotfix-15607'],
    }
    $all_provisioning_steps = concat(
      $provisioning_steps,
      Class['::aem_resources::author_remove_default_agents'],
    )
  } else {
    $all_provisioning_steps = $provisioning_steps
  }

  # Ensure login page is still ready after all provisioning steps and before stopping AEM.
  aem_aem { 'Ensure login page is ready':
    ensure  => login_page_is_ready,
    require => $all_provisioning_steps,
  }

  $keystore_path = pick(
    $aem_keystore_path,
    "${aem_base}/aem/${aem_role}/crx-quickstart/ssl/aem.ks",
  )

  file { dirname($keystore_path):
    ensure  => directory,
    mode    => '0770',
    owner   => 'aem',
    group   => 'aem',
    require => [
      Aem_aem['Ensure login page is ready'],
    ],
  }

  $x509_parts = [ 'key', 'cert' ]
  $x509_parts.each |$idx, $part| {
    ensure_resource(
      'archive',
      "${cert_temp_dir}/aem.${part}",
      {
        'ensure' => 'present',
        'source' => "${cert_base_url}/aem.${part}",
      },
    )
  }
  $java_ks_require = $x509_parts.map |$part| {
    Archive["${cert_temp_dir}/aem.${part}"]
  }

  java_ks { "cqse:${keystore_path}":
    ensure       => latest,
    certificate  => "${cert_temp_dir}/aem.cert",
    private_key  => "${cert_temp_dir}/aem.key",
    password     => $aem_keystore_password,
    trustcacerts => true,
    require      => $java_ks_require,
  }
  -> class { '::aem_resources::author_publish_enable_ssl':
    run_mode            => $aem_role,
    port                => 5433,
    keystore            => $keystore_path,
    keystore_password   => $aem_keystore_password,
    keystore_key_alias  => 'cqse',
    truststore          => '/usr/java/default/jre/lib/security/cacerts',
    truststore_password => 'changeit',
  }
  -> class { '::config::aem_cleanup':
    aem_base => $aem_base,
  }


  if $setup_repository_volume {
    exec { 'service aem-aem stop':
      require => [
        Class['::config::aem_cleanup'],
        Mount[$repository_volume_mount_point],
      ],
    }
    -> exec { 'sleep 120':
    }
    -> exec { "mv ${aem_base}/aem/${aem_role}/crx-quickstart/repository/* ${repository_volume_mount_point}/":
    }
    -> file { "${aem_base}/aem/${aem_role}/crx-quickstart/repository/":
      ensure => 'link',
      owner  => 'aem',
      group  => 'aem',
      force  => true,
      target => $repository_volume_mount_point,
    }
  }

}
