class base (
  $rhn_register = false,
  $disable_selinux = true,
  $install_aws_cli = true
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
      version    => 'system',
      pip        => 'present'
    }

    python::pip { 'awscli' :
      pkgname       => 'awscli',
      ensure        => 'present',
      virtualenv    => 'system',
      owner         => 'root',
      timeout       => 1800,
    }

  }

  class { 'serverspec':
    stage     => 'test',
    component => 'base',
    tries     => 5,
    try_sleep => 3,
  }

}

include base
