#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: ./setconfig.sh <local_hiera_path> <local_packer_path>'
  exit 1
fi

local_hiera_path=$1
local_packer_path=$2

echo "Copying custom files"
cp -vf "$local_hiera_path" conf/hieradata/
cp -vf "$local_packer_path" vars/
