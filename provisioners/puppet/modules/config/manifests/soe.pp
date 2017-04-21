# == Class: config::soe
#
# Basic SOE module for AEM AMIs
#
# === Parameters
#
# [*proxy_server_name*]
#   The name of the proxy server to configure. If this value is not set, the
#   proxy settings are skipped.
#
# [*proxy_server_port*]
#   The port of the proxy server to configure.
#
# [*proxy_no_proxy*]
#   A list of sites to which should bypass the proxy. This list is joined with
#   commas to produce the `no_proxy` environment variable.
#
# [*proxy_profile_sh_file*]
#   The path where the shell snippet that exports the proxy environment
#   variables should be placed.
#
# [*proxy_yum_file*]
#   The path to the `yum` configuration file.
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
  String $proxy_server_name = '',
  String $proxy_server_port = '3128',
  Array[String] $proxy_no_proxy = [
    '127.0.0.1',
    '169.254.169.254',
  ],
  String $proxy_profile_sh_file = '/etc/profile.d/proxy.sh',
  String $proxy_yum_file = '',
) {
  include ::config
  include ::config::amz_linux_cis_benchmark

  File {
    owner => root,
    group => root,
    mode  => '0644',
  }

  if $proxy_server_name != '' {
    # Configure proxy servers.
    $epp_template_params = {
      'proxy_name' => $proxy_server_name,
      'proxy_port' => $proxy_server_port,
      'no_proxy'   => $proxy_no_proxy,
    }
    if $proxy_profile_sh_file != '' {
      file { $proxy_profile_sh_file:
        ensure  => file,
        content => epp('config/proxy.sh.epp', $epp_template_params),
      }
    }
    if $proxy_yum_file != '' {
      file_line { 'yum proxy line':
        path  => $proxy_yum_file,
        line  => "proxy=http://${proxy_server_name}:${proxy_server_port}",
        match => '^proxy\=',
      }
    }
  }
}
