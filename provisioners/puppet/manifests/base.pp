class base (
  $tmp_dir,
  $packer_user,
  $packer_group,
  $python_package,
  $python_pip_package,
  $python_cheetah_package,
  $rhn_register = false,
  $disable_selinux = true,
  $install_aws_cli = true,
  $install_cloudwatchlogs = true,
  $install_aws_agents = true,
  $aws_agents_install_url = 'https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install',
){

  stage { 'test':
    require => Stage['main']
  }

  class { 'timezone': }

  if ($::osfamily == 'redhat') and ($::operatingsystem != 'Amazon') {

    if $rhn_register {
      class { 'rhn_register':
        use_classic => false,
      }
    }

    if $disable_selinux {
      # issue with selinux stopping aem:dispatcher to start. https://github.com/bstopp/puppet-aem/issues/73
      class { 'selinux':
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

  # if $install_aws_agents {
  #
  #   #TODO: create a puppet module for installing the aws agent. push it up to puppet forge.
  #   file { "${tmp_dir}/awsagent":
  #     ensure => directory,
  #     mode   => '0775',
  #     owner  => $packer_user,
  #     group  => $packer_group
  #   } ->
  #   wget::fetch { $aws_agents_install_url:
  #     destination => "${tmp_dir}/awsagent/install",
  #     timeout     => 0,
  #     verbose     => false,
  #   } ->
  #   file { "${tmp_dir}/awsagent/install":
  #     ensure => file,
  #     mode   => '0755',
  #     owner  => $packer_user,
  #     group  => $packer_group
  #   } ->
  #   exec { "${tmp_dir}/awsagent/install":
  #     path    => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/bin/bash',
  #   }
  #
  # }

  # needed for running Serverspec, used for testing baked AMIs and provisioned EC instances
  package { [ 'gcc', 'ruby-devel', 'zlib-devel' ]:
    ensure  => 'installed',
  }
  package { 'bundler':
    provider => 'gem',
  }
}

include base
