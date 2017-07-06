# == Class: config::aem_cleanup
#
#  Clean up after installing AEM
#
# === Parameters
#
# [*aem_base*]
#   Base directory for installing AEM.
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
class config::aem_cleanup (
  $aem_base,
) {
  exec { "rm -f ${aem_base}/aem/aem-healthcheck-content-*.zip": }
}
