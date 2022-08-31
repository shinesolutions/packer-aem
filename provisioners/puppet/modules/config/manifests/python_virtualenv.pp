define config::python_virtualenv (
  $virtualenv_dir = '/home/.virtualenvs',
) {

  # install virtualenv package in default python

  class { '::python':
    version => 'system',
    ensure  => 'present',
    dev     => 'present',
  }

  file { $virtualenv_dir:
    ensure => 'directory',
    owner  => 'root',
    mode   => '0755'
  }

  python::pyvenv { "${virtualenv_dir}/py3":
    ensure     => present,
    version    => 'system',
    owner      => 'root',
    group      => 'root',
    systempkgs => true
  }

}
