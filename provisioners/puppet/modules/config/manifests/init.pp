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
) {
  # Ensure we have a working FQDN <=> IP mapping.
  host { $facts['fqdn']:
    ensure       => present,
    ip           => $facts['ipaddress'],
    host_aliases => $facts['hostname'],
  }
  # needed for running Serverspec, used for testing baked AMIs and provisioned EC instances
  package { [ 'gcc', 'ruby-devel', 'zlib-devel' ]:
    ensure  => 'installed',
  } -> package { [ 'bundler', 'io-console' ]:
    provider => 'gem',
  } -> package { 'ruby_aem':
    ensure   => '1.4.1',
    provider => 'puppet_gem',
  }
  # inspec '1.46.2' requires ruby > 2.2
  # -> package { 'inspec':
  #   ensure   => '1.46.2',
  #   provider => 'puppet_gem',
  # }
  # work around to install inspec for ruby < 2.2
  -> package { 'mixlib-shellout':
    ensure   => '2.2.7',
    provider => 'puppet_gem',
  }
  -> package { 'inspec':
    ensure   => '1.17.0',
    provider => 'puppet_gem',
  }
}
