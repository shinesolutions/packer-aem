# == Class: config::base
#
# Basic configuration AEM AMIs
#
# === Parameters
#
# [*tmp_dir*]
#   A temporary directory used for staging
#
# [*python_package*]
# [*python_pip_package*]
# [*python_cheetah_package*]
#   System package manager names for the Python, pip and cheetah packages.
#
# [*rhn_register*]
#   Boolean that determines whether the instance should be registered with the RedHat Network.
#
# [*disable_selinux*]
#   Boolean that determines whether SELinux is disabled.
#
# [*install_aws_cli*]
#   Boolean that determines whether `awscli` will be installed.
#
# [*install_cloudwatchlogs*]
#   Boolean that determines whether `cloudwatchlogs` will be installed.
#
# === Authors
#
# James Sinclair <james.sinclair@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017 Shine Solutions Group, unless otherwise noted.
#
class config::base (
  $tmp_dir,
  $python_package,
  $python_pip_package,
  $python_cheetah_package,
  $rhn_register = false,
  $disable_selinux = true,
  $install_aws_cli = true,
  $install_cloudwatchlogs = true,
) {
  require ::config::soe

  class { '::timezone': }

  if ($::osfamily == 'redhat') and ($::operatingsystem != 'Amazon') {

    if $rhn_register {
      class { '::rhn_register':
        use_classic => false,
      }
    }

    if $disable_selinux {
      # issue with selinux stopping aem:dispatcher to start. https://github.com/bstopp/puppet-aem/issues/73
      class { '::selinux':
        mode => 'disabled',
      }
    }
  }

  file_line { 'sudo_rule_keep_proxy_vairables':
    path => '/etc/sudoers',
    line => 'Defaults    env_keep += "ftp_proxy http_proxy https_proxy no_proxy"',
  }

  package { [ $python_package, $python_pip_package, $python_cheetah_package ]:
    ensure => latest,
  }

  package { [ 'boto3', 'requests', 'retrying' ]:
    ensure   => latest,
    provider => 'pip',
  }

  if $install_aws_cli {
    package { 'awscli':
      ensure   => latest,
      provider => 'pip',
    }
  }

  if $install_cloudwatchlogs {
    class { '::cloudwatchlogs': }
  }
  
}
