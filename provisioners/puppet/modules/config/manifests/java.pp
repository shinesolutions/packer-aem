# == Class: config::java
#
# Configuration AEM Java AMIs
#
# === Parameters
#
# [*tmp_dir*]
#   A temporary directory used for staging
#
# === Authors
#
# James Sinclair <james.sinclair@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017 Shine Solutions Group, unless otherwise noted.
#
class config::java (
) {
  require ::config::base
  contain ::jdk_oracle
}
