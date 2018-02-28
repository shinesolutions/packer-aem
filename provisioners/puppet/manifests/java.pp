include ::config::base

include aem_curator::install_java

if $::config::base::install_cloudwatchlogs {
  include config::cloudwatchlogs_java
}
