# == Class: config::java
#
# Configuration AEM Java AMIs
#
# === Parameters
#
# [*tmp_dir*]
#   A temporary directory used for staging
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
) {
  require ::config::base

  class { '::oracle_java':
    version         => '8u112',
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

  if $::config::base::install_collectd {
    $collectd_jmx_types_path = '/usr/share/collectd/jmx.db'
    collectd::plugin::genericjmx::mbean {
      'garbage_collector':
        object_name     => 'java.lang:type=GarbageCollector,*',
        instance_prefix => 'gc-',
        instance_from   => 'name',
        values          => [
          {
            type      => 'invocations',
            table     => false,
            attribute => 'CollectionCount',
          },
          {
            type            => 'total_time_in_ms',
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
            type      => 'jmx_memory',
            table     => true,
            attribute => 'HeapMemoryUsage',
          },
        ];
      'memory-nonheap':
        object_name     => 'java.lang:type=Memory',
        instance_prefix => 'memory-nonheap',
        values          => [
          {
            type      => 'jmx_memory',
            table     => true,
            attribute => 'NonHeapMemoryUsage',
          },
        ];
      'memory-permgen':
        object_name     => 'java.lang:type=MemoryPool,name=*Perm Gen',
        instance_prefix => 'memory-permgen',
        values          => [
          {
            type      => 'jmx_memory',
            table     => true,
            attribute => 'Usage',
          },
        ];
    }
  }
}
