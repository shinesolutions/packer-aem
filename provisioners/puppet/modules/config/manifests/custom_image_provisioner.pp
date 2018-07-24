Exec {
  path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
}

class config::custom_image_provisioner (
  $source_file,
  $install_dir,
  $enable_custom_image_provisioner = false,
) {

  if $enable_custom_image_provisioner {

    exec { "Extract Custom Image Provisioner to ${install_dir}":
      command => "mkdir -p ${install_dir} && tar -xvzf ${source_file} --directory ${install_dir}",
      onlyif  => "test -e ${source_file} && ! test -e ${install_dir}",
    }

  }

}
