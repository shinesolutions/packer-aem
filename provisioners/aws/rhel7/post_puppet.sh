#!/usr/bin/env bash
set -o nounset
set -o errexit

# Clean up temporary files
rm -rf /tmp/shinesolutions/packer-aem

# Clear history
history -c
