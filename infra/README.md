# Infrastructure

This folder contains Terraform code only. Application code, Docker files, Jenkins files, and Kubernetes manifests should remain outside `infra/`.

## Structure

- `backend.tf`: Remote Terraform state stored in S3 with DynamoDB state locking
- `provider.tf`: Terraform and AWS provider configuration
- `main.tf`: Root module wiring, shared data sources, and module composition
- `variables.tf`: Input variables for the infrastructure stack
- `outputs.tf`: Useful values for CI/CD and cluster access
- `modules/ecr`: Amazon ECR repositories for application images
- `modules/eks`: Local child module that wraps the EKS cluster and managed node group
- `modules/iam`: IAM roles and policy attachments for EKS

## Cost notes

- The configuration reuses the default VPC and default subnets instead of creating a dedicated VPC and NAT gateways.
- The EKS managed node group defaults to a single `t3.small` instance.
- The EKS managed node group defaults to a single `t3.small` SPOT instance.
- ECR lifecycle policies retain only a small number of recent images to limit storage growth.
- ECR image scanning is configured as `scan_on_push = true` for security without adding extra infrastructure components.

## Assumptions

- The AWS account already has a default VPC and at least two default subnets in different availability zones.

## Usage

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
terraform init \
  -backend-config="bucket=<tf-state-bucket>" \
  -backend-config="key=<env>/terraform.tfstate" \
  -backend-config="region=<aws-region>" \
  -backend-config="dynamodb_table=<tf-lock-table>"
terraform plan
terraform apply
```
