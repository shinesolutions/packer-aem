#!/usr/bin/env bash

#echo "export http_proxy=$HTTP_PROXY" | sudo tee --append /etc/profile.d/http_proxy.sh
#echo "export https_proxy=$HTTPS_PROXY" | sudo tee --append /etc/profile.d/http_proxy.sh
#
#sudo chmod 755 /etc/profile.d/http_proxy.sh
#
#echo "export proxy=$HTTP_PROXY" | sudo tee --append /etc/yum.comf


sudo cat /etc/yum.comf

sudo ls -ltr /etc/profile.d/

echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
