# == Class: config::license
#
# A Puppet module to retrieve the AEM license file from AWS Service Manager Parameter Store
# and store in the temp folder
#
# === Parameters
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

  if ! ($aem_license in [ '', 'overwrite-me' ]) {
    # Download the License file from Parameter Store
    exec { 'Download License file from AWS Systems Manager Parameter Store':
      creates => "${tmp_dir}/license/license-${aem_version}.properties",
      command => "aws ssm get-parameters --region ${region} --names ${aem_license} --with-decryption --output text --query Parameters[0].Value > ${tmp_dir}/license/license-${aem_version}.properties",
      path    => '/usr/local/bin/:/bin/',
    }
  }
  else {
    # Download the License file from S3
    archive { "${tmp_dir}/license/license-${aem_version}.properties":
      ensure  => present,
      source  => "${aem_license_base}/license-${aem_version}.properties",
      require => File["${tmp_dir}/license"],
    }
  }

  file { "${tmp_dir}/license/license-${aem_version}.properties":
    ensure => file,
    mode   => '0644',
  }

}
