# == Class: config::author
#
# Install AEM and configure for the `publish` role.
#
# === Parameters
#
# [*aem_port*]
#   TCP port AEM will listen on.
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
class config::publish (
  $aem_port = '4503',
) {
  class { '::config::aem':
    aem_role => 'publish',
    aem_port => $aem_port,
  }
}
