# == Class: config::tomcat
#
# Configure Tomcat during baking proces
#
# === Parameters
#
# [*pkg_name*]
#   Package name of tomcat package
#   Default value: tomcat
#
# [*srv_name*]
#   Service name of tomcat
#   Default value: tomcat
#
class config::tomcat (
  $pkg_name = 'tomcat',
  $srv_name = 'tomcat',
  ) {
    package { [ $pkg_name ]:
    ensure => latest,
    } -> service { $srv_name:
      ensure => stopped,
      enable => false,
    }
  }
