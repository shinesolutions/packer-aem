class author (
  $tmp_dir,
  $aem_quickstart_source,
  $aem_license_source,
  $aem_artifacts_base,
  $aem_healthcheck_version,
  $aem_repo_mount_point,
  $aem_base           = '/opt',
  $aem_jvm_mem_opts   = '-Xss4m -Xmx8192m',
  $aem_port           = '4502',
  $aem_sample_content = false,
  $sleep_secs         = 120
) {

  stage { 'test':
    require => Stage['main']
  }
  stage { 'shutdown':
    require => Stage['test'],
  }

  Exec {
    cwd  => '/tmp',
    path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
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
  } ->
  file { "${aem_base}/aem/author/aem-author-${aem_port}.jar":
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
  } ->
  file { "${aem_base}/aem/author/license.properties":
    ensure => file,
    mode   => '0440',
    owner  => 'aem',
    group  => 'aem',
  }

  aem::instance { 'aem':
    source         => "${aem_base}/aem/author/aem-author-${aem_port}.jar",
    home           => "${aem_base}/aem/author",
    type           => 'author',
    port           => $aem_port,
    sample_content => $aem_sample_content,
    jvm_mem_opts   => $aem_jvm_mem_opts,
    jvm_opts       => '-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime -XX:+HeapDumpOnOutOfMemoryError',
    status         => 'running',
  } ->
  # Confirm AEM starts up and the login page is ready.
  aem_aem { 'Wait until login page is ready':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 60,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
  } ->
  exec { 'Manual delay to let AEM become ready':
    command => "sleep ${sleep_secs}",
  } ->
  aem_install_package { 'cq-6.2.0-hotfix-11490':
    group          => 'adobe/cq620/hotfix',
    version        => '1.2',
    artifacts_base => $aem_artifacts_base,
  } ->
  aem_install_package { 'cq-6.2.0-hotfix-12785':
    group                   => 'adobe/cq620/hotfix',
    version                 => '7.0',
    artifacts_base          => $aem_artifacts_base,
    restart                 => true,
    post_install_sleep_secs => $sleep_secs,
  } ->
  aem_install_package { 'aem-service-pkg':
    file_name               => 'AEM-6.2-Service-Pack-1-6.2.SP1.zip',
    group                   => 'adobe/cq620/servicepack',
    artifacts_base          => $aem_artifacts_base,
    version                 => '6.2.SP1',
    post_install_sleep_secs => $sleep_secs,
  } ->
  aem_install_package { 'cq-6.2.0-sp1-cfp':
    file_name                   => 'AEM-6.2-SP1-CFP1-1.0.zip',
    group                       => 'adobe/cq620/cumulativefixpack',
    artifacts_base              => $aem_artifacts_base,
    version                     => '1.0',
    post_install_sleep_secs     => $sleep_secs,
    post_login_page_ready_sleep => $sleep_secs,
  } ->
  aem_install_package { 'aem-healthcheck-content':
    group                       => 'shinesolutions',
    version                     => $aem_healthcheck_version,
    post_install_sleep_secs     => $sleep_secs,
    post_login_page_ready_sleep => $sleep_secs,
    artifacts_base              => "http://central.maven.org/maven2/com/shinesolutions/aem-healthcheck-content/${aem_healthcheck_version}",
  }


  class { 'aem_resources::author_remove_default_agents':
    require => [Aem_install_package['aem-healthcheck-content']],
  }

  class { 'aem_resources::create_system_users':
    require => [Aem_install_package['aem-healthcheck-content']],
  }

  # Ensure login page is still ready after all provisioning steps and before stopping AEM.
  aem_aem { 'Ensure login page is ready':
    ensure                     => login_page_is_ready,
    retries_max_tries          => 30,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
    require                    => [
      Class['aem_resources::author_remove_default_agents'],
      Class['aem_resources::create_system_users'],
    ]
  } ->
  class { 'serverspec':
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
  }

  exec { "mv ${author::aem_base}/aem/author/crx-quickstart/repository/* ${author::aem_repo_mount_point}/":
    cwd  => "${author::tmp_dir}",
    path => '/usr/bin',
  } ->
  file { "${author::aem_base}/aem/author/crx-quickstart/repository/":
    ensure => 'link',
    owner  => 'aem',
    group  => 'aem',
    force  => true,
    target => "${author::aem_repo_mount_point}",
  }
}

define aem_install_package (
  $group,
  $version,
  $artifacts_base,

  $file_name = '',
  $replicate = false,
  $activate  = false,
  $force     = true,
  $restart   = false,

  $tmp_dir = '/tmp/aem_install_tmp',

  $post_install_sleep_secs     = 0,
  $post_restart_sleep_secs     = 120,
  $post_login_page_ready_sleep = 0,

  $retries_max_tries          = 120,
  $retries_base_sleep_seconds = 5,
  $retries_max_sleep_seconds  = 5,
) {

  Exec {
    cwd  => '/tmp',
    path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
  }


  if !defined(File[$tmp_dir]) {
    file { $tmp_dir:
      ensure => directory,
    }
  }

  $local_file_name = "${title}-${version}.zip"

  $url_file_name = case $file_name {
    '': { $local_file_name }
    default: { $file_name }
  }

  $local_file_path = "${tmp_dir}/${local_file_name}"

  archive { $local_file_path:
    ensure  => present,
    source  => "${artifacts_base}/${url_file_name}",
    cleanup => false,
    require => File[$tmp_dir],
  } ->
    aem_package { "Install ${title}":
      ensure    => present,
      name      => $title,
      group     => $group,
      version   => $version,
      path      => $tmp_dir,
      replicate => $replicate,
      activate  => $activate,
      force     => $force,
    } ->
    exec { "Wait post install of ${title}":
      command => "sleep ${post_install_sleep_secs}",
    }

  if $restart {
    exec { "Stop post install of ${title}":
      command => 'service aem-aem stop',
      require => Exec["Wait post install of ${title}"],
    } ->
      exec { "Wait post stop with ${title}":
        command => 'sleep 240',
      }
    exec { "Start post install of ${title}":
      command => 'service aem-aem start',
      require => Exec["Wait post install of ${title}"],
    } ->
      exec { "Wait post restart with ${title}":
        command => "sleep ${post_restart_sleep_secs}",
      }
    $restart_exec = [Exec["Wait post restart with ${title}"]]
  } else {
    $restart_exec = []
  }

  aem_aem { "Wait for login page post ${title}":
    ensure                     => login_page_is_ready,
    retries_max_tries          => 120,
    retries_base_sleep_seconds => 5,
    retries_max_sleep_seconds  => 5,
    require                    =>
      [Exec["Wait post install of ${title}"]] + $restart_exec,
  } ->
    exec { "Wait post login page for ${title}":
      command => "sleep ${post_login_page_ready_sleep}",
    }
}

include author
