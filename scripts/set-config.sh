#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 1 ] || [ "$#" -gt 3 ]; then
  echo 'Usage: ./set-config.sh <local_hiera_file> <local_packer_file> <local_tag_file>'
  exit 1
fi

BASEDIR=$(dirname "$0")

local_hiera_file=$1
local_packer_file=$2
local_tag_file=$3

echo "Copying custom files"
cp -vf "$local_hiera_file" conf/hieradata/local.yaml
cp -vf "$local_packer_file" vars/99_local.json

echo "Executing global tag addition script: $local_tag_file"
python $BASEDIR/add-global-tags.py $BASEDIR/../templates/ "$local_tag_file"
