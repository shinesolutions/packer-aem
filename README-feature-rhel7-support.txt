===========================================
Notes for the feature-rhel7-support branch


You can remove this file when you don't this anymore.
This is an information
===========================================


(   search for (sshim) for important code highlights  )

1. Disabled 'collectd' in RedHat/RedHat.yaml due to the following error:

ami_base: Error: Could not find dependency File[/usr/lib/python2.7/site-packages] for File[cloudwatch_writer.script] at /tmp/packer-puppet-masterless/module-0/collectd/manifests/plugin/python/module.pp:22




_ Modifications

Turned off 'collectd' in RedHat.yaml (config::base::collectd_packages)

Turned off Serverspec uniaem_spec.rb

Turned off installation of Hotfixes (see aem_cfp3.pp)

_Features

Altered /packer-aem/provisioners/puppet/modules/config/manifests/aem.pp (Line: 251)
We want the service name to be 'aem-author' or 'aem-publisher' instead of 'aem-aem'
[Will affect anything calling aem-aem]

Added $aem_ssl_port, (Line: 86) to /packer-aem/provisioners/puppet/modules/config/manifests/aem.pp
This allows Author and Publisher to be installed on different https ports.
[Will affect stackbuilder secgrps]



90_base_ami pointed to 7.4
