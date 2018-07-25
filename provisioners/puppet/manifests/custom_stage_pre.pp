Exec {
  path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
}

class { 'config::custom_image_provisioner':
} -> exec { 'Execute Custom Image Provisioner pre step':
  command   => "${config::custom_image_provisioner::install_dir}/pre-common.sh",
  logoutput => true,
  onlyif    => "test -x ${config::custom_image_provisioner::install_dir}/pre-common.sh",
}
