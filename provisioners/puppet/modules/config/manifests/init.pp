# == Class: config
#
# Configuration for AEM AMIs
#
# === Parameters
#
# [*newrelic_releasever*]
#   The release version to use when constructing the repo baseurl.
#
# [*newrelic_architecture*]
#   The architecture to use when constructing the repo baseurl.
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
  $newrelic_releasever = '$releasever',
  $newrelic_architecture = $::facts[os][architecture]
) {
  # needed for running Serverspec, used for testing baked AMIs and provisioned EC instances
  package { [ 'gcc', 'ruby-devel', 'zlib-devel' ]:
    ensure  => 'installed',
  }
  -> package { [ 'bundler', 'io-console' ]:
    provider => 'gem',
  }
  -> package { 'nokogiri':
    ensure   => '1.6.8.1',
    provider => 'puppet_gem',
  }
  -> package { 'ruby_aem':
    ensure   => '1.0.12',
    provider => 'puppet_gem',
  }
  yumrepo { 'newrelic-infra':
    ensure  => present,
    descr   => 'New Relic Infrastructure',
    baseurl => "http://download.newrelic.com/infrastructure_agent/linux/yum/el/${newrelic_releasever}/${newrelic_architecture}",
    gpgkey  => 'https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg',
    enabled => true,
  }
}
