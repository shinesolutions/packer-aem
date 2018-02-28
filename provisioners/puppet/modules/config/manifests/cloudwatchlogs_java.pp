define config::cloudwatchlogs_java (
) {

  # Orchestrator Logs
  # e.g. 2018-02-28 13:03:09 [SessionCallBackSchedulerThread-1] INFO  c.s.a.s.OrchestratorMessageL
  cloudwatchlogs::log { '/opt/shinesolutions/aem-orchestrator/orchestrator.log':
    datetime_format => '%Y-%m-%d %H:%M:%S',
    notify          => Service['awslogs'],
  }

  # Simian Army Logs
  # e.g. 2018-02-28 15:22:20.348 - INFO  Monkey - [Monkey.java:132] VOLUME_TAGGING Monkey Running
  cloudwatchlogs::log { '/var/log/tomcat/simianarmy.log':
    datetime_format => '%Y-%m-%d %H:%M:%S.%f',
    notify          => Service['awslogs'],
  }

}
