include ::config::base

include ::config::certs

include aem_curator::install_java

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_java { 'Setup CloudWatch for Java': }
}

include config::tomcat
