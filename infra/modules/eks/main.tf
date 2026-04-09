# Discover the default VPC so the cluster can reuse existing networking.
# This avoids creating a dedicated VPC, NAT gateways, elastic IPs, and extra route tables.
data "aws_vpc" "default" {
  default = true
}

# Discover the default subnets that belong to the default VPC.
# Reusing these subnets keeps the EKS footprint minimal and avoids separate private subnet infrastructure.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Use the community-maintained EKS module inside this child module.
# The root module only wires dependencies while this module owns the EKS implementation details.
module "this" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # Create the EKS control plane with the requested cluster name.
  # The version remains optional so AWS can choose the default supported version when needed.
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Reuse IAM roles created by the dedicated IAM child module instead of letting the upstream module create extra roles.
  create_iam_role = false
  iam_role_arn    = var.cluster_role_arn

  # Reuse the default VPC and subnets discovered above to avoid additional networking cost.
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = sort(data.aws_subnets.default.ids)

  # Enable a minimal set of control plane logs for operational visibility.
  # Logging is useful, but each enabled stream adds CloudWatch cost, so keep the list intentionally small.
  cluster_enabled_log_types = var.enabled_log_types

  # Grant the Terraform caller initial admin access so the cluster is immediately manageable after apply.
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  # Keep the endpoint public for a lean setup that does not require private endpoints or extra network plumbing.
  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  # Create a single small SPOT-backed managed node group to minimize EC2 and EBS cost.
  # This is intentionally lean and suitable for a low-cost non-production baseline.
  eks_managed_node_groups = {
    default = {
      name           = "ecommerce-spot-nodes"
      instance_types = var.instance_types
      capacity_type  = "SPOT"

      # Reuse the pre-created worker node IAM role so permissions stay explicit and modular.
      create_iam_role = false
      iam_role_arn    = var.node_role_arn

      # Keep node counts intentionally small for a cost-optimized non-production baseline.
      # One worker keeps baseline EC2 and EBS charges low while still keeping the cluster schedulable.
      min_size     = 1
      desired_size = 1
      max_size     = 2

      # Keep root volumes small while still satisfying the minimum size EKS expects for worker nodes.
      # Smaller disks directly reduce per-node EBS cost.
      disk_size  = var.node_disk_size
      subnet_ids = sort(data.aws_subnets.default.ids)

      tags = merge(
        var.tags,
        {
          Name      = "ecommerce-spot-nodes"
          CostScope = "eks-workers"
        }
      )
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}
