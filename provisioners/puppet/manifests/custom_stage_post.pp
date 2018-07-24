Exec {
  path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
}

class { 'config::custom_image_provisioner':
} -> exec { 'Execute Custom Image Provisioner post step':
  command => "${config::custom_image_provisioner::install_dir}/post-common.sh",
  onlyif  => "test -x ${config::custom_image_provisioner::install_dir}/post-common.sh",
}
