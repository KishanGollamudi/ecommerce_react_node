# Define a short project identifier that is reused in resource names and tags.
variable "project_name" {
  description = "Project name used as the naming prefix for AWS resources."
  type        = string
  default     = "ecommerce-platform"
}

# Define the AWS region used by the provider and supporting infrastructure services.
variable "region" {
  description = "AWS region where the infrastructure is deployed."
  type        = string
  default     = "ap-south-1"
}

# Define the environment label used in names, tags, and outputs.
variable "environment" {
  description = "Deployment environment name such as dev, staging, or prod."
  type        = string
  default     = "dev"
}

# Define the optional EKS Kubernetes version. When null, AWS chooses the default supported version.
variable "cluster_version" {
  description = "Optional EKS control plane version."
  type        = string
  default     = null
  nullable    = true
}

# Define the EKS cluster name used by kubectl, Argo CD, and CI/CD tooling.
variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string
  default     = "ecommerce-cluster"
}

# Define which control plane logs should be enabled for the EKS cluster.
variable "eks_enabled_log_types" {
  description = "List of EKS control plane log types to enable."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

# Define whether the EKS API endpoint should be publicly accessible.
variable "eks_cluster_endpoint_public_access" {
  description = "Whether the EKS cluster endpoint is publicly accessible."
  type        = bool
  default     = true
}

# Define whether the Terraform caller should automatically become a cluster admin.
variable "enable_cluster_creator_admin_permissions" {
  description = "Whether the Terraform caller receives initial EKS cluster admin permissions."
  type        = bool
  default     = true
}

# Define the EC2 instance types used by the EKS managed node group.
variable "instance_types" {
  description = "EC2 instance types used by the EKS managed node group."
  type        = list(string)
  default     = ["t3.small"]
}

# Define the root volume size for each worker node.
# Cost note: smaller disks reduce EBS charges, but must still fit images, logs, and kubelet state.
variable "node_disk_size" {
  description = "Disk size in GiB for EKS worker nodes."
  type        = number
  default     = 20

  validation {
    condition     = var.node_disk_size >= 20
    error_message = "Worker node disk size must be at least 20 GiB."
  }
}

# Define how many container images ECR should keep per repository to control storage cost.
variable "ecr_image_retention_count" {
  description = "Number of images to retain per ECR repository."
  type        = number
  default     = 5

  validation {
    condition     = var.ecr_image_retention_count > 0
    error_message = "The ECR image retention count must be greater than 0."
  }
}

# Define any extra tags that should be merged with the standard project tags.
variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
