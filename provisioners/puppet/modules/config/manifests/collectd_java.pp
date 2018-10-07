define config::collectd_java (
) {

  collectd::plugin { ['java']:
    ensure => present,
  }

}
