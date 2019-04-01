# == Class: config::certs
#
# A Puppet module to retrieve a certificate from ACM and certificate key from AWS Secret Manager
# and store in the temp folder
#
# === Parameters
#
# [*certs_base*]
#   Source URL path of TLS certificate and key, it could be s3://..., http://..., https://..., or file://....
#
# [*certificate_key_arn*]
#   ARN of certificate key to retrieve from AWS Secrets Manager
#
# [*certificate_arn*]
#   ARN of certificate to retrieve from AWS Certificate Manager (ACM)
#
# [*tmp_dir*]
#   Directory to store the certs and key in before they are removed.
#
# [*region*]
#   The AWS region the certificate and secret are located in
#
# === Authors
#
# Ryan Siebert <ryan.siebert@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2018	Shine Solutions Group, unless otherwise noted.
#
class config::certs (
  $certs_base,
  $certificate_key_arn,
  $certificate_arn,
  $tmp_dir,
  $region,
) {

  exec { "Create ${tmp_dir}/certs":
    creates => "${tmp_dir}/certs",
    command => "mkdir -p ${tmp_dir}/certs",
    path    => '/usr/local/bin/:/bin/',
  }

  file { "${tmp_dir}/certs":
    ensure => directory,
    mode   => '0700',
  }

  # Get SSL certificate based on ARN from:
  #  - Certificate Manager (arn:aws:acm)
  #  - IAM Server Certificates (arn:aws:iam)
  #  - S3 (s3:)
  case $certificate_arn {
    /^arn:aws:acm/: {
      exec { 'Download Certificate from AWS Certificate Manager using cli':
        creates => "${tmp_dir}/certs/aem.cert",
        command => "aws acm get-certificate --region ${region} --certificate-arn ${certificate_arn} --output text --query Certificate > ${tmp_dir}/certs/aem.cert",
        path    => '/usr/local/bin/:/bin/',
        require => File["${tmp_dir}/certs"],
      }
    }
    /^arn:aws:iam/: {
      $certificate_name = $certificate_arn.split('/')[1]
      exec { 'Download Certificate from IAM (Server Certificates) using cli':
        creates => "${tmp_dir}/certs/aem.cert",
        command => "aws iam get-server-certificate --server-certificate-name ${certificate_name} --query 'ServerCertificate.CertificateBody' --output text > ${tmp_dir}/certs/aem.cert",
        path    => '/usr/local/bin/:/bin/',
        require => File["${tmp_dir}/certs"],
      }
    }
    /^s3:/: {
      archive { "${tmp_dir}/certs/aem.cert":
        ensure  => present,
        source  => "${$certificate_arn}",
        require => File["${tmp_dir}/certs"],
      }
    }
    default: {
      fail('Certificate ARN can only be of types: ( arn:aws:acm | arn:aws:iam | s3: )')
    }
  }

  # chmod the certificate
  file { "${tmp_dir}/certs/aem.cert":
    ensure => file,
    mode   => '0600',
  }

  # Get certificate private key from Secrets Manager
  if ! ($certificate_key_arn in [ '', 'overwrite-me' ]) {
    exec { 'Download Secret from AWS Secrets Manager using cli':
      creates => "${tmp_dir}/certs/aem.key",
      command => "aws secretsmanager get-secret-value --region ${region} --secret-id ${certificate_key_arn} --output text --query SecretString > ${tmp_dir}/certs/aem.key",
      path    => '/usr/local/bin/:/bin/',
    }
  }
  elsif ! ($certs_base in [ '', 'overwrite-me' ]) {
    # S3 is the fallback as AWS Secrets Manager isn't currently SOC2 compliant
    # The support for S3 as a fallback can be removed as soon as AWS Secrets Manager is SOC2 compliant and listed on [ASM Compliance with Standards](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html#asm_compliance)
    archive { "${tmp_dir}/certs/aem.key":
      ensure  => present,
      source  => "${certs_base}/aem.key",
      require => File["${tmp_dir}/certs"],
    }
  }

  file { "${tmp_dir}/certs/aem.key":
    ensure => file,
    mode   => '0600',
  }

}
