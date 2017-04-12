# == Class: config::aem_cleanup
#
#  Clean up after installing AEM
#
# === Parameters
#
# [*aem_base*]
#   Base directory for installing AEM.
#
# [*aem_healthcheck_version*]
#   The version of the AEM healthcheck service to clean up.
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
  $aem_healthcheck_version,
) {
  exec { "rm -f ${aem_base}/aem/aem-healthcheck-content-${aem_healthcheck_version}.zip": }
}
