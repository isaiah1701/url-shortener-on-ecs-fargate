#!/bin/bash 

if terraform plan -target=module.ecr -var-file=dev.tfvars; then 

terraform apply -target=module.ecr -var-file=dev.tfvars --auto-approve

repo = $(terraform output -raw ecr_repo_url)
docker tag isaiah4748/urlshortener "$repo:latest"
docker push "$repo:latest"

aws ecr get-login-password --region eu-west-2 \
| docker login --username AWS --password-stdin 044941685411.dkr.ecr.eu-west-2.amazonaws.com

echo 
"failed plan , try again buddy "
fi 