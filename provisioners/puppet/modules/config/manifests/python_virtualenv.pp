define config::python_virtualenv (
  $virtualenv_dir,
) {

  # allow the system have two python virtual environments
  include pip
  pip::install { 'virtualenv':
    ensure  => present,
    version => '16.7.9',
  }

  class { '::python':
    version => 'system',
    ensure  => 'present',
    dev     => 'present',
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
    timeout    => 0,
  }

  python::virtualenv { "${virtualenv_dir}/py27":
    ensure  => present,
    version => '2.7',
    owner   => 'root',
    group   => 'root',
    timeout => 0,
  }
}