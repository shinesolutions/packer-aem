define config::cloudwatch_metric_agent (
  $disk_path, $autoscaling=true
) {
  class { '::cloudwatch':
      enable_mem_util         => true,
      enable_mem_used         => true,
      enable_mem_avail        => true,
      enable_disk_space_util  => true,
      enable_disk_space_used  => true,
      enable_disk_space_avail => true,
      enable_swap_util        => false,
      enable_swap_used        => false,
      auto_scaling            => $autoscaling,
      cron_min                => '*',
      disk_path               => $disk_path,
      zip_url                 => 'https://github.com/shinesolutions/aws-scripts-mon/releases/download/1.3.0/shinesolutions-aws-scripts-mon-1.3.0.zip',
    }

}
