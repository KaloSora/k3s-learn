# Purpose
This repository mainly use terraform to create vm and deploy k3s on AWS EC2.

[My Blog - AWS and Tencent Cloud K3s](https://kalosora.github.io/2026/01/19/K3S-deployment/)

## Terraform init
```
cd ./modules
terraform init -backend-config="bucket=795359014551-terraform-state"
```

## Create EC2
```
terraform apply -target=module.k3s-ec2 -var-file="./aws-k3s.tfvars" --auto-approve
```

Login and verify kubectl command


## Destroy EC2
```
terraform destroy -target=module.k3s-ec2 -var-file="./aws-k3s.tfvars" --auto-approve
```
