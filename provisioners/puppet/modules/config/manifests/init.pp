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
  package { [ 'gcc', 'gcc-c++', 'ruby-devel', 'zlib-devel' ]:
    ensure  => 'installed',
  # needed for ffi (a ruby_aem dependency) native compilation
  } -> package { [ 'autoconf', 'automake', 'libtool' ]:
    ensure => installed,
  } -> package { 'io-console':
    provider => 'gem',
  # TODO: upgrade to bundler >= 2.0.1 when all machine images includes Ruby >= 2.3.0
  # This bundler is used for the initial gem installation on the host
  } -> package { 'bundler':
    ensure   => '1.17.3',
    provider => 'gem',
  } -> package { 'nokogiri':
    ensure   => '1.8.5',
    provider => 'puppet_gem',
  } -> package { 'ruby_aem':
    ensure   => '2.5.1',
    provider => 'puppet_gem',
  } -> package { 'ruby_aem_aws':
    ensure   => '1.4.0',
    provider => 'puppet_gem',
  } -> package { 'inspec':
    ensure   => '1.51.6',
    provider => 'puppet_gem',
  }
}
