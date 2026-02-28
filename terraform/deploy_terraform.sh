#!/bin/bash
source set_variables.sh
./get_metadata.py > metadata.yml.tmp
terraform apply
rm metadata.yml.tmp
