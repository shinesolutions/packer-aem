# == Class: config::aem_install_package
#
#  Download and install an AEM package.
#
# === Parameters
#
#   The AEM package group.
#
# [*artifacts_base*]
#   The base URL for downloading the artifact.
#
# [*file_name*]
#   The file name of the artifact zip. Default is ${title}-${version}.zip
#
# [*version*]
#   The AEM package version. Used to generate *file_name* and passed to
#   aem_package resource.
#
# [*group*]
# [*replicate*]
# [*activate*]
# [*force*]
#   Passed directly to the aem_package resource.
#
# [*restart*]
#   Boolean which controls whether to restart AEM after installing the package.
#
# [*tmp_dir*]
#   Temporary directory for storing files. Default is '/tmp/aem_install_tmp'.
#
# [*post_install_sleep_secs*]
#   Number of seconds to sleep for after installing the package. Default 120.
#
# [*post_restart_sleep_secs*]
#   Number of seconds to sleep for after restarting AEM. Default 120.
#
# [*post_login_page_ready_sleep*]
#   Number of seconds to sleep for after login page becomes ready. Default 0.
#
# [*retries_max_tries*]
# [*retries_base_sleep_seconds*]
# [*retries_max_sleep_seconds*]
#   Passed directly to the aem_aem resource when waiting for login page to
#   become ready.
#
# === Authors
#
# James Sinclair <james.sinclair@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017 Shine Solutions Group, unless otherwise noted.
#
define config::aem_install_package (
  $group,
  $version,
  $artifacts_base,

  $file_name = '',
  $replicate = false,
  $activate  = false,
  $force     = true,
  $restart   = false,

  $tmp_dir = '/tmp/aem_install_tmp',

  $post_install_sleep_secs     = 120,
  $post_restart_sleep_secs     = 120,
  $post_login_page_ready_sleep = 0,

  $retries_max_tries          = 120,
  $retries_base_sleep_seconds = 5,
  $retries_max_sleep_seconds  = 5,
) {
  Exec {
    cwd     => '/tmp',
    path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    timeout => 0,
  }

  Aem_aem {
    retries_max_tries          => $retries_max_tries,
    retries_base_sleep_seconds => $retries_base_sleep_seconds,
    retries_max_sleep_seconds  => $retries_max_sleep_seconds,
  }

  if !defined(File[$tmp_dir]) {
    file { $tmp_dir:
      ensure => directory,
    }
  }

  $local_file_name = "${title}-${version}.zip"
  $url_file_name = pick($file_name, $local_file_name)

  $local_file_path = "${tmp_dir}/${local_file_name}"

  archive { $local_file_path:
    ensure  => present,
    source  => "${artifacts_base}/${url_file_name}",
    cleanup => false,
    require => File[$tmp_dir],
  }
  -> aem_package { "Install ${title}":
    ensure    => present,
    name      => $title,
    group     => $group,
    version   => $version,
    path      => $tmp_dir,
    replicate => $replicate,
    activate  => $activate,
    force     => $force,
  }
  -> exec { "Wait post install of ${title}":
    command => "sleep ${post_install_sleep_secs}",
  }

  if $restart {
    exec { "Wait pre stop with ${title}":
      command => 'sleep 120',
    }
    -> aem_aem { "Wait for login page before restart ${title}":
      ensure  => login_page_is_ready,
      require => Exec["Wait post install of ${title}"],
    }
    -> exec { "Wait post login page before restart for ${title}":
      command => "sleep ${post_login_page_ready_sleep}",
    }
    -> aem_aem { "Wait until aem health check is ok before restart ${title}":
      ensure => aem_health_check_is_ok,
      tags   => 'deep',
    }
    -> exec { "Stop post install of ${title}":
      command => 'service aem-aem stop',
    }
    -> exec { "Wait post stop with ${title}":
      command => 'sleep 120',
    }
    -> exec { "Start post install of ${title}":
      command => 'service aem-aem start',
    }
    -> exec { "Wait post start with ${title}":
      command => "sleep ${post_restart_sleep_secs}",
    }
    $restart_exec = [Exec["Wait post start with ${title}"]]
  } else {
    $restart_exec = []
  }

  aem_aem { "Wait for login page post ${title}":
    ensure  => login_page_is_ready,
    require => [Exec["Wait post install of ${title}"]] + $restart_exec,
  }
  -> aem_aem { "Wait until aem health check is ok post ${title}":
    ensure => aem_health_check_is_ok,
    tags   => 'deep',
  }
  -> exec { "Wait post login page for ${title}":
    command => "sleep ${post_login_page_ready_sleep}",
  }
}
