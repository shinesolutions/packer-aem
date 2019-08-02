# == Class: config
#
# Configuration for AEM AMIs
#
# === Parameters
#
#
# === Authors
#
# James Sinclair <james.sinclair@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017	Shine Solutions Group, unless otherwise noted.
#
class config (
  $package_manager_packages = {},
) {
  # Ensure we have a working FQDN <=> IP mapping.
  host { $facts['fqdn']:
    ensure       => present,
    ip           => $facts['ipaddress'],
    host_aliases => $facts['hostname'],
  }

  $package_manager_packages.each | Integer $index, $package_details| {

    $package_name = $package_details['name']

    $package_version = pick(
      $package_details['version'],
      'latest'
    )

    $package_provider = pick(
      $package_details['provider'],
      false
    )

    if $package_provider {
      package { $package_name:
        ensure   => $package_version,
        provider => $package_provider,
      }
    } else {
      package { $package_name:
        ensure   => $package_version,
      }
    }
  }
}
