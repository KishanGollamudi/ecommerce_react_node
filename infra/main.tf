# Centralize naming and tagging so every module follows the same conventions.
locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  # Build a shared naming prefix once so every child module receives consistent names.
  name_prefix = "${var.project_name}-${var.environment}"
}

# Create the application image repositories in Amazon ECR.
# This module is independent and provides repository URLs used later by CI/CD systems.
module "ecr" {
  source = "./modules/ecr"

  name_prefix           = local.name_prefix
  image_retention_count = var.ecr_image_retention_count
  tags                  = local.common_tags
}

# Create explicit IAM roles for the EKS control plane and worker nodes.
# The EKS child module consumes these role ARNs instead of creating IAM resources on its own.
module "iam" {
  source = "./modules/iam"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

# Create the EKS cluster through a local child module so the root module remains a clean parent orchestrator.
# This module depends on the IAM module for cluster and node role ARNs.
# The child module performs its own default VPC and subnet lookup so no separate network stack or NAT gateway is created here.
module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Pass IAM outputs from the IAM child module into the EKS child module.
  cluster_role_arn = module.iam.cluster_role_arn
  node_role_arn    = module.iam.node_role_arn

  # Pass cluster-level operational settings into the EKS child module.
  enabled_log_types                         = var.eks_enabled_log_types
  cluster_endpoint_public_access            = var.eks_cluster_endpoint_public_access
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  # Pass the low-cost worker configuration from the root module into the EKS child module.
  instance_types = var.instance_types
  node_disk_size = var.node_disk_size

  # Pass shared tags from the root module so all child modules stay consistent.
  tags = local.common_tags
}
