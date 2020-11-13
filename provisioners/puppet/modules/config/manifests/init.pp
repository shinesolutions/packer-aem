# == Class: config
#
# Configuration for AEM AMIs
#
# === Parameters
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

  if ($::osfamily == 'redhat') and ($::operatingsystem != 'Amazon') {
    file { '/sbin/ebsnvme-id':
      ensure => present,
      source => 'puppet:///modules/config/nvme/ebsnvme-id.py',
      mode   => '0755',
      owner  => 'root',
      group  => 'root'
    }

    file { '/usr/lib/udev/ec2nvme-nsid':
      ensure  => present,
      source  => 'puppet:///modules/config/nvme/ec2nvme-nsid.sh',
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      require => File['/sbin/ebsnvme-id'],
    }

    udev::rule { '70-ec2-nvme-devices.rules':
      ensure  => present,
      source  => "puppet:///modules/${module_name}/nvme/udev.rules",
      notify  => Class['udev::udevadm::trigger'],
      require => File['/usr/lib/udev/ec2nvme-nsid']
    }
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
