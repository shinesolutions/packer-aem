include ::config::base

include aem_curator::install_java

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_java { 'Setup CloudWatch for Java': }
}

if $::config::base::install_collectd {
  class { 'collectd::plugin::java':
    manage_package => true,
  }
}
