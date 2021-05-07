#!/bin/bash
terraform -chdir=base init
terraform -chdir=base plan -var-file=../admin.auto.tfvars
read -p "Press enter to continue"
terraform -chdir=base apply -var-file=../admin.auto.tfvars --auto-approve
# apply