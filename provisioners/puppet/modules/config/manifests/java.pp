# == Class: config::java
#
# Configuration AEM Java AMIs
#
# === Parameters
#
# [*cert_base_url*]
#   Base URL (supported by the puppet-archive module) to download the X.509
#   certificate and private key to be used with Apache.
#
# [*cert_temp_dir*]
#   A temporary directory used to store the X.509 certificate and private key
#   while building the PEM file for Apache.
#
# === Authors
#
# James Sinclair <james.sinclair@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017 Shine Solutions Group, unless otherwise noted.
#
class config::java (
  $cert_base_url,
  $cert_temp_dir,
) {
  include ::config::base

  class { '::oracle_java':
    version         => '8u131',
    type            => 'jdk',
    add_alternative => true,
  }

  file { '/etc/ld.so.conf.d/99-libjvm.conf':
    ensure  => present,
    content => "/usr/java/latest/jre/lib/amd64/server\n",
    notify  => Exec['/sbin/ldconfig'],
  }

  exec { '/sbin/ldconfig':
    refreshonly => true,
  }

  file { $cert_temp_dir:
    ensure => directory,
    mode   => '0700',
  }

  [ 'cert' ].each |$idx, $part| {
    archive { "${cert_temp_dir}/aem.${part}":
      ensure  => present,
      source  => "${cert_base_url}/aem.${part}",
      require => File[$cert_temp_dir],
    }
    -> java_ks { "cqse-${idx}:/usr/java/default/jre/lib/security/cacerts":
      ensure      => latest,
      certificate => "${cert_temp_dir}/aem.${part}",
      password    => 'changeit',
    }
  }

  if $::config::base::install_collectd {
    $collectd_jmx_types_path = '/usr/share/collectd/jmx.db'
    collectd::plugin::genericjmx::mbean {
      'garbage_collector':
        object_name     => 'java.lang:type=GarbageCollector,*',
        instance_prefix => 'gc-',
        instance_from   => 'name',
        values          => [
          {
            'type'    => 'invocations',
            table     => false,
            attribute => 'CollectionCount',
          },
          {
            'type'          => 'total_time_in_ms',
            instance_prefix => 'collection_time',
            table           => false,
            attribute       => 'CollectionTime',
          },
        ];
      'memory-heap':
        object_name     => 'java.lang:type=Memory',
        instance_prefix => 'memory-heap',
        values          => [
          {
            'type'    => 'jmx_memory',
            table     => true,
            attribute => 'HeapMemoryUsage',
          },
        ];
      'memory-nonheap':
        object_name     => 'java.lang:type=Memory',
        instance_prefix => 'memory-nonheap',
        values          => [
          {
            'type'    => 'jmx_memory',
            table     => true,
            attribute => 'NonHeapMemoryUsage',
          },
        ];
      'memory-permgen':
        object_name     => 'java.lang:type=MemoryPool,name=*Perm Gen',
        instance_prefix => 'memory-permgen',
        values          => [
          {
            'type'    => 'jmx_memory',
            table     => true,
            attribute => 'Usage',
          },
        ];
    }
  }
}
