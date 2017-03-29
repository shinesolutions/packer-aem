class java (
  $tmp_dir,
  $aem_cert_source,
  $install_collectd = true,
  $collectd_cloudwatch_source_url = 'https://github.com/awslabs/collectd-cloudwatch/archive/master.tar.gz',
) {

  stage { 'test':
    require => Stage['main']
  }

  class { '::oracle_java':
    version         => '8u121',
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

  archive { "${tmp_dir}/aem.cert":
    ensure => present,
    source => $aem_cert_source,
  }
  java_ks { 'Add cert to default Java truststore':
    ensure      => latest,
    name        => 'cqse',
    certificate => "${tmp_dir}/aem.cert",
    target      => '/usr/java/default/jre/lib/security/cacerts',
    password    => 'changeit',
  }

  if $install_collectd {

    $collectd_plugins = [
      'syslog', 'cpu', 'interface', 'load', 'memory',
    ]

    $collectd_jmx_types_path = '/usr/share/collectd/jmx.db'

    $collectd_cloudwatch_base_dir = '/opt/collectd-cloudwatch'

    file { '/opt/collectd-cloudwatch':
      ensure => directory,
    }

    archive { '/tmp/collectd-cloudwatch.tar.gz':
      extract       => true,
      extract_path  => $collectd_cloudwatch_base_dir,
      extract_flags => '--strip-components=1 -xvzf',
      creates       => "${collectd_cloudwatch_base_dir}/src/cloudwatch_writer.py",
      source        => $collectd_cloudwatch_source_url,
      cleanup       => true,
    }

    class { '::collectd':
      purge           => true,
      recurse         => true,
      purge_config    => true,
      minimum_version => '5.4',
      package_ensure  => latest,
      service_ensure  => stopped,
      service_enable  => false,
      typesdb         => [
        '/usr/share/collectd/types.db',
        $collectd_jmx_types_path,
      ],
    }

    file { $collectd_jmx_types_path:
      ensure  => present,
      content => file('config/collectd_jmx_types.db'),
      require => Package[$::collectd::install::package_name],
    }

    collectd::plugin { $collectd_plugins:
      ensure => present,
    }

    class { '::collectd::plugin::python':
      modulepaths => [
        '/usr/lib/python2.7/dist-packages',
        '/usr/lib/python2.7/site-packages',
        "${collectd_cloudwatch_base_dir}/src",
      ],
      logtraces   => true,
    }


    collectd::plugin::python::module {'cloudwatch_writer':
      script_source => 'puppet:///modules/config/cloudwatch_writer.py',
    }

    $cloudwatch_memory_stats = [
      'used', 'buffered', 'cached', 'free',
    ]

    $cloudwatch_memory_stats.each |$stat| {
      file_line { "${stat} memory":
        ensure  => present,
        line    => "memory--memory-${stat}",
        path    => "${collectd_cloudwatch_base_dir}/src/cloudwatch/config/whitelist.conf",
        require => Collectd::Plugin::Python::Module['cloudwatch_writer'],
      }
    }

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

  class { 'serverspec':
    stage             => 'test',
    component         => 'java',
    staging_directory => "${tmp_dir}/packer-puppet-masterless-java",
    tries             => 5,
    try_sleep         => 3,
  }

}

include java
