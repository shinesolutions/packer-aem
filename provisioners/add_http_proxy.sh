#!/usr/bin/env bash

#TODO: add condition to add proxy or not.
echo "export http_proxy=$HTTP_PROXY" | sudo tee --append /etc/profile.d/proxy.sh
echo "export https_proxy=$HTTPS_PROXY" | sudo tee --append /etc/profile.d/proxy.sh

sudo chmod 755 /etc/profile.d/proxy.sh
