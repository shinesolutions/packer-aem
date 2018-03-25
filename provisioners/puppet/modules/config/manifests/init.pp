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
  # needed for ffi (a ruby_aem dependency) native compilation
  } -> package { [ 'autoconf', 'automake', 'libtool' ]:
    ensure => installed,
  } -> package { [ 'bundler', 'io-console' ]:
    provider => 'gem',
  } -> package { 'ruby_aem':
    ensure   => '1.4.1',
    provider => 'puppet_gem',
  } -> package { 'inspec':
    ensure   => '1.46.2',
    provider => 'puppet_gem',
  }
}
