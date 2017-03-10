# == Class: config::author
#
# Install AEM and configure for the `publisher` role.
#
# === Parameters
#
# [*tmp_dir*]
#   A temporary directory used for staging
#
# [*aem_dispatcher_source*]
#
#
# [*filename*]
# [*tmp_dir*]

# [*aem_healthcheck_version*]
#   The version of the AEM healthcheck service to install.
#
# [*module_filename*]
# [*packer_user*]
#
# [*packer_group*]
#
# === Authors
#
# Andy Wang <andy.wang@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017 Shine Solutions Group, unless otherwise noted.
#

class config::dispatcher (
  $aem_dispatcher_source,
  $filename,
  $tmp_dir,
  $module_filename,
  $packer_user,
  $packer_group
) {

  include apache

  file { "${tmp_dir}":
    ensure => directory,
    owner  => $packer_user,
    group  => $packer_group,
    mode   => '0775',
  }

  archive { "${filename}":
    path         => "${tmp_dir}/${filename}",
    extract      => true,
    extract_path => "${tmp_dir}",
    source       => $aem_dispatcher_source,
    cleanup      => true,
    require      => File["${tmp_dir}"],
    user         => $packer_user,
    group        => $packer_group,
  }

  class { 'aem::dispatcher' :
    module_file => "${tmp_dir}/${module_filename}",
  } ->
  exec { 'httpd -k graceful':
    cwd  => "${tmp_dir}",
    path => ['/sbin','/usr/sbin'],
  }

}
