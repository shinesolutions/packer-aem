# == Class: config::author
#
# Install AEM and configure for the `publisher` role.
#
# === Parameters
#
# [*cert_base_url*]
#   Base URL (supported by the puppet-archive module) to download the X.509
#   certificate and private key to be used with Apache.
#
# [*cert_filename*]
#   The local path and filename to save the X.509 certificate and private key
#   to be used with Apache.
#
# [*cert_temp_dir*]
#   A temporary directory used to store the X.509 certificate and private key
#   while building the PEM file for Apache.
#
# [*apache_module_base_url*]
#   Base URL (supported by the puppet-archive module) to download the archive
#   containing the AEM Dispatcher Apache module.
#
# [*apache_module_tarball*]
#   The name of the archive containing the AEM Dispatcher Apache module.
#
# [*apache_module_filename*]
#   The name of the AEM Dispatcher Apache module shared object file stored
#   inside the archive.
#
# [*apache_module_temp_dir*]
#   A temporary directory used to store the AEM Dispatcher Apache module while
#   installing it.
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
class config::dispatcher (
  $cert_base_url,
  $cert_filename,
  $cert_temp_dir,

  $apache_module_base_url,
  $apache_module_tarball,
  $apache_module_filename,
  $apache_module_temp_dir,
) {
  include ::config::base

  # Prepare AEM certificate
  concat { $cert_filename:
    mode  => '0600',
    order => 'numeric',
  }

  file { $cert_temp_dir:
    ensure => directory,
    mode   => '0700',
  }

  [ 'key', 'cert' ].each |$idx, $part| {
    archive { "${cert_temp_dir}/aem.${part}":
      ensure  => present,
      source  => "${cert_base_url}/aem.${part}",
      require => File[$cert_temp_dir],
    }
    -> concat::fragment { "${cert_filename}:${part}":
      target => $cert_filename,
      source => "${cert_temp_dir}/aem.${part}",
      order  => $idx,
    }
  }

  $apache_classes = [
    '::apache',
    '::apache::mod::ssl',
    '::apache::mod::headers',
  ]
  class { $apache_classes: }

  archive { $apache_module_tarball:
    source       => "${apache_module_base_url}/${apache_module_tarball}",
    path         => "${apache_module_temp_dir}/${apache_module_tarball}",
    extract      => true,
    extract_path => $apache_module_temp_dir,
  }

  class { '::aem::dispatcher' :
    module_file => "${apache_module_temp_dir}/${apache_module_filename}",
  }
}
