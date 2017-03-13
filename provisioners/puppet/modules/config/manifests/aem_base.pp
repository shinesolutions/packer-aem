# == Class: config::aem_base
#
# Shared Resources used by other AEM modules
#
# === Parameters
#
# [*tmp_dir*]
#   A temporary directory used for staging
#
# [*aem_repo_device*]
#
# [*aem_healthcheck_version*]
#   The version of the AEM healthcheck service to install.
#
# [*aem_base*]
#   Base directory for installing AEM.
#
# [*aem_repo_mount_point*]
#
# === Authors
#
# Andy Wang <andy.wang@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017 Shine Solutions Group, unless otherwise noted.
#

class config::aem_base (
  $tmp_dir,
  $aem_repo_device,
  $aem_healthcheck_version,
  $aem_repo_mount_point,
  $aem_base = '/opt'
) {

  exec { 'Prepare device for AEM repository':
    command => "mkfs -t ext4 ${aem_repo_device}",
    path    => ['/sbin'],
  } ->
  file { $aem_repo_mount_point:
    ensure => directory,
    mode   => '0755',
  } ->
  mount { $aem_repo_mount_point:
    ensure   => mounted,
    device   => $aem_repo_device,
    fstype   => 'ext4',
    options  => 'nofail,defaults,noatime',
    remounts => false,
    atboot   => false,
  }

  file { "${aem_base}/aem":
    ensure => directory,
    mode   => '0775',
  }

  # Retrieve Healthcheck Content Package and move into aem directory
  archive { "${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip":
    ensure  => present,
    source  => "http://central.maven.org/maven2/com/shinesolutions/aem-healthcheck-content/${aem_healthcheck_version}/aem-healthcheck-content-${aem_healthcheck_version}.zip",
    cleanup => false,
    require => File["${aem_base}/aem"],
  } ->
  file { "${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip":
    ensure => file,
    mode   => '0664',
  }
}
