#!/bin/sh
az login --scope https://management.core.windows.net//.default --use-device-code 
az account set --subscription="VES PLM - Sponsorship"
az account list --output table
