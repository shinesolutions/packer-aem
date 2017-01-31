class base (
  $packer_user,
  $packer_group,
  $rhn_register = false,
  $disable_selinux = true,
  $install_aws_cli = true,
  $install_cloudwatchlogs = true,
  $install_aws_agents = true,
  $aws_agents_install_url = 'https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install'
){

  stage { 'test':
    require => Stage['main']
  }

  class { 'timezone': }

  if $::osfamily == 'redhat' {

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

  if $install_aws_cli {

    class { 'python' :
      version => 'system',
      pip     => 'present'
    }

    python::pip { 'awscli' :
      ensure     => 'present',
      pkgname    => 'awscli',
      virtualenv => 'system',
      owner      => 'root',
      timeout    => 1800,
    }

  }

  if $install_cloudwatchlogs {

    class { '::cloudwatchlogs': }

  }

  # if $install_aws_agents {
  #
  #   #TODO: create a puppet module for installing the aws agent. push it up to puppet forge.
  #   file { '/tmp/awsagent':
  #     ensure => directory,
  #     mode   => '0775',
  #     owner  => $packer_user,
  #     group  => $packer_group
  #   } ->
  #   wget::fetch { $aws_agents_install_url:
  #     destination => '/tmp/awsagent/install',
  #     timeout     => 0,
  #     verbose     => false,
  #   } ->
  #   file { '/tmp/awsagent/install':
  #     ensure => file,
  #     mode   => '0755',
  #     owner  => $packer_user,
  #     group  => $packer_group
  #   } ->
  #   exec { '/tmp/awsagent/install':
  #     path    => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/bin/bash',
  #   }
  #
  # }

  package { 'gcc':
    ensure  => 'installed',
  }

  package { 'ruby-devel':
    ensure  => 'installed',
  }

  package { 'zlib-devel':
    ensure  => 'installed',
  }

  # cloud-init's preferred rendering engine
  package { 'python-cheetah':
    ensure  => installed,
  }

  # needed to run Serverspec to test the provisioned CloudFormation stack
  package { 'rake':
    ensure   => '12.0.0',
    provider => 'gem',
  }

  class { 'serverspec':
    stage     => 'test',
    component => 'base',
    tries     => 5,
    try_sleep => 3,
  }

}

include base
