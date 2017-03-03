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
class config () {
  # needed for running Serverspec, used for testing baked AMIs and provisioned EC instances
  package { [ 'gcc', 'ruby-devel', 'zlib-devel' ]:
    ensure  => 'installed',
  }
  package { [ 'bundler', 'io-console' ]:
    provider => 'gem',
  }
}
