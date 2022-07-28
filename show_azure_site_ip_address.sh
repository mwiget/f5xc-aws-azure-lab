#!/bin/bash
jq -r .resources[].instances[0].attributes.tf_output  terraform.tfstate | grep '\0' |grep ^master
