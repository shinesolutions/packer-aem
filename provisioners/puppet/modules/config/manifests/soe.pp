# == Class: config::soe
#
# Basic SOE module for AEM AMIs
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
class config::soe (
) {
  include ::config
  include ::config::amz_linux_cis_benchmark

  File {
    owner => root,
    group => root,
  }

}
