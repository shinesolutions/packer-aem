===========================================
Notes for the feature-rhel7-support branch


You can remove this file when you don't this anymore.
This is an information
===========================================


(   search for (sshim) for important code highlights  )

1. Disabled 'collectd' in RedHat/RedHat.yaml due to the following error:

ami_base: Error: Could not find dependency File[/usr/lib/python2.7/site-packages] for File[cloudwatch_writer.script] at /tmp/packer-puppet-masterless/module-0/collectd/manifests/plugin/python/module.pp:22
