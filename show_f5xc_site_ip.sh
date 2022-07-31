#!/bin/bash
jq -r .resources[].instances[].attributes.tf_output  terraform.tfstate | grep "master\|az"
