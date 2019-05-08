# == Class: config::license
#
# A Puppet module to retrieve the AEM license file from AWS Service Manager Parameter Store
# and store in the temp folder
#
# === Parameters
#
# [*aem_profile*]
#   AEM Profile consisting of version, service pack etc..
#
# [*aem_license*]
#   AWS Systems Manager parameter containing the License content.
#
# [*aem_license_base*]
#   Source URL folder path of License file, it could be s3://..., http://..., https://..., or file://.....
#
# [*tmp_dir*]
#   Directory to store the certs and key in before they are removed.
#
# [*region*]
#   The AWS region the certificate and secret are located in
#
# === Authors
#
# Stephen Shim <stephen.shim@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2019	Shine Solutions Group, unless otherwise noted.
#
class config::license (
  $aem_profile,
  $aem_license,
  $aem_license_base,
  $tmp_dir,
  $region,
  $license_value = lookup("${aem_license}"),
) {

  # TODO: This code is a workaround, this needs a better conversion that can map any aem_profile into any aem_version
  case $aem_profile {
    /^aem62/:  { $aem_version = '6.2' }
    /^aem63/:  { $aem_version = '6.3' }
    /^aem64/:  { $aem_version = '6.4' }
    /^aem65/:  { $aem_version = '6.5' }
    default: { $aem_version = '6.4' }
  }

  exec { "Create ${tmp_dir}/license/":
    creates => "${tmp_dir}/license",
    command => "mkdir -p ${tmp_dir}/license",
    path    => '/usr/local/bin/:/bin/',
  }

  file { "${tmp_dir}/license/":
    ensure => directory,
    mode   => '0700',
  }

  file { "${tmp_dir}/license/license-${aem_version}.properties":
    ensure  => file,
    mode    => '0644',
    content => $license_value,
  }

}
