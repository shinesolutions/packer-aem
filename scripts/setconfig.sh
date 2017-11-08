#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: ./setconfig.sh <local_yaml_path> <local_json_path>'
  exit 1
fi

echo "Copying custom files"
cp -vf "$1" conf/hieradata/
cp -vf "$2" vars/
