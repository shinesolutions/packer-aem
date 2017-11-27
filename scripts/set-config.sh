#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 1 ] || [ "$#" -gt 3 ]; then
  echo 'Usage: ./set-config.sh <tags_file> <hieradata_file> <packer_vars_file>'
  exit 1
fi

BASEDIR=$(dirname "$0")

tags_file=$1
hieradata_file=$2
packer_vars_file=$3

echo "Setting up Hieradata and Packer vars configuration files..."
cp -vf "$hieradata_file" "$BASEDIR/../conf/hieradata/local.yaml"
cp -vf "$packer_vars_file" "$BASEDIR/../vars/99_local.json"

echo "Setting up AWS tags..."
python "$BASEDIR/add-global-tags.py" "$BASEDIR/../templates/" "$tags_file"
