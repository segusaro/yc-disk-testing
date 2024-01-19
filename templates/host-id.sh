#!/bin/bash

eval "$(jq -r '@sh "folder_id=\(.folder_id) az_name=\(.az_name)"')"

yc compute host-group create host-group --fixed-size 1 --type intel-6338-c108-m704-n3200x6 --zone $az_name --folder-id $folder_id > /dev/null 2>&1
export host_id=$(yc compute host-group list-hosts host-group --folder-id $folder_id --format json | jq -r '.[] .id')
jq -n --arg host_id "$host_id" '{"host_id":$host_id}'
