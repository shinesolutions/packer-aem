class base (
  $rhn_register = false,
  $disable_selinux = true
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

  class { 'serverspec':
    stage     => 'test',
    component => 'base',
    tries     => 5,
    try_sleep => 3,
  }

}

include base
