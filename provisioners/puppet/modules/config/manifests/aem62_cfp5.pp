class config::aem62_cfp5() {

  config::aem_install_package { 'cq-6.2.0-hotfix-11490':
    group   => 'adobe/cq620/hotfix',
    version => '1.2',
  }
  -> config::aem_install_package { 'cq-6.2.0-hotfix-12785':
    group                       => 'adobe/cq620/hotfix',
    version                     => '7.0',
    restart                     => true,
    post_install_sleep_secs     => 150,
    post_login_page_ready_sleep => 30,
  }
  -> config::aem_install_package { 'aem-service-pkg':
    file_name => 'AEM-6.2-Service-Pack-1-6.2.SP1.zip',
    group     => 'adobe/cq620/servicepack',
    version   => '6.2.SP1',
  }
  -> config::aem_install_package { 'cq-6.2.0-sp1-cfp':
    file_name               => 'AEM-6.2-SP1-CFP5-5.0.zip',
    group                   => 'adobe/cq620/cumulativefixpack',
    post_install_sleep_secs => 900,
    version                 => '5.0',
  }
  -> config::aem_install_package { 'cq-6.2.0-hotfix-15607':
    group   => 'adobe/cq620/hotfix',
    version => '1.0',
  }

}
