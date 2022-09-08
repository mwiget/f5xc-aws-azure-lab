#!/bin/bash
set -e
for site in azure-1a azure-1b aws-2a aws-2b gcp-3a gcp-3b; do
  workload="mwlab-$site-workload"
  for remote in site1 site2 site3; do
    echo -n "$workload curl workload.$remote ... "
    result=$(ssh -o "StrictHostKeyChecking=no" ubuntu@$workload curl -s workload.$remote | grep 'Short Name' && echo "good" || echo "failed")
    echo $result
  done
done
