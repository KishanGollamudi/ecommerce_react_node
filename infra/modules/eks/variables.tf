# Define the EKS cluster name.
variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string
  default     = "ecommerce-cluster"
}

# Define the optional Kubernetes version for the control plane.
variable "cluster_version" {
  description = "Optional Kubernetes version for the EKS control plane."
  type        = string
  default     = null
  nullable    = true
}

# Define the IAM role ARN that the EKS control plane should use.
variable "cluster_role_arn" {
  description = "IAM role ARN attached to the EKS control plane."
  type        = string
}

# Define the IAM role ARN that managed worker nodes should use.
variable "node_role_arn" {
  description = "IAM role ARN attached to the EKS managed node group."
  type        = string
}

# Define which control plane log streams should be enabled.
variable "enabled_log_types" {
  description = "List of control plane log types enabled for the EKS cluster."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

# Define whether the EKS endpoint is exposed publicly.
variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API endpoint is publicly accessible."
  type        = bool
  default     = true
}

# Define whether the cluster creator should receive admin access automatically.
variable "enable_cluster_creator_admin_permissions" {
  description = "Whether the Terraform caller receives initial cluster admin permissions."
  type        = bool
  default     = true
}

# Define the EC2 instance types used by the low-cost managed node group.
variable "instance_types" {
  description = "EC2 instance types used by the EKS managed node group."
  type        = list(string)
  default     = ["t3.small"]
}

# Define the root EBS volume size attached to worker nodes.
variable "node_disk_size" {
  description = "Disk size in GiB for each managed worker node."
  type        = number
  default     = 20
}

# Define the common tags passed down from the root module.
variable "tags" {
  description = "Common tags applied to EKS resources."
  type        = map(string)
  default     = {}
}
