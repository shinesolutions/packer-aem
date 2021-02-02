define config::python_virtualenv (
  $virtualenv_dir,
) {

  # install virtualenv package in default python

  class { '::python':
    version    => 'system',
    ensure     => 'present',
    dev        => 'present',
    virtualenv => 'present',
  }

  file { $virtualenv_dir:
    ensure => 'directory',
    owner  => 'root',
    mode   => '0755',
  }

  python::virtualenv { "${virtualenv_dir}/py3":
    ensure     => present,
    version    => '3',
    owner      => 'root',
    group      => 'root',
    distribute => false,
    systempkgs => true,
    timeout    => 0,
  }

}
