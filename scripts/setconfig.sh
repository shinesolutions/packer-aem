#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: ./setconfig.sh <local_hiera_file> <local_packer_file>'
  exit 1
fi

local_hiera_file=$1
local_packer_file=$2

echo "Copying custom files"
cp -vf "$local_hiera_file" conf/hieradata/local.yaml
cp -vf "$local_packer_file" vars/99_local.json
