class java (
  $tmp_dir,
) {

  stage { 'test':
    require => Stage['main']
  }

  include jdk_oracle

  class { 'serverspec':
    stage             => 'test',
    component         => 'java',
    staging_directory => "${tmp_dir}/packer-puppet-masterless-java",
    tries             => 5,
    try_sleep         => 3,
  }

}

include java
