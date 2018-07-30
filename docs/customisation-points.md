Customisation Points
--------------------

Since every user has a unique standard operating environment and security requirements, Packer AEM provides two customisation points where user can provision any specific setup.

### Source Image

Common software and settings need to be provisioned in a source image, which will then be used as the base image of all components.

For example, if you need to install [Splunk Universal Forwarder](https://www.splunk.com/en_us/download/universal-forwarder.html) on all components, then it should be provisioned in the source image.

For AWS, the source AMI ID can be configured in `aws.source_ami`.

For Docker, the source Docker image name can be configured in `docker.source`.

### Custom Image Provisioner

For component-specific software and settings, they can be provisioned using Custom Image Provisioner, which provides a pre step to be executed before provisioning the component itself, and a post step to be executed after.

For example, if you need to set up component-specific configuration for the Splunk Universal Forwarder, then these configurations need to be bundled within the Custom Image Provisioner artifact and the set up steps could be executed in either the pre or post step.

In order to use Custom Image Provisioner, you need to:
1. Set the configuration property `aem.enable_custom_image_provisioner` to `true`
2. Place the artifact at `stage/custom/aem-custom-image-provisioner.tar.gz`
3. Optionally, if you want to pass in additional runtime info to the provisioner, you can pass an environment variable to the build command `CUSTOM_STAGE_RUN_INFO="Build 123 using Custom Image Provisioner 456" make aws-java config_path=<path/to/config/dir>"`

To get an idea how this artifact should be structured, please have a look at the example repository [AEM Hello World Custom Image Provisioner](https://github.com/shinesolutions/aem-helloworld-custom-image-provisioner).
