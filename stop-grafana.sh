#!/bin/bash
for site in aws-2a aws-2b azure-1a azure-1b gcp-3a gcp-3b; do
  echo $site ...
  ssh -o StrictHostKeyChecking=no ubuntu@mwlab-$site-workload sudo systemctl stop grafana-agent
done
