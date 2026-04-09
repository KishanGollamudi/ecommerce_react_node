# Expose the cluster name for kubectl, CI/CD, and Argo CD integration.
output "cluster_name" {
  description = "Name of the created Amazon EKS cluster."
  value       = module.this.cluster_name
}

# Expose the API endpoint required for kubeconfig generation.
output "cluster_endpoint" {
  description = "API server endpoint for the EKS cluster."
  value       = module.this.cluster_endpoint
}

# Expose the certificate authority data required for kubeconfig generation.
output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the EKS cluster."
  value       = module.this.cluster_certificate_authority_data
}

# Expose the managed node groups created by the child module.
output "eks_managed_node_groups" {
  description = "Managed node groups created for the EKS cluster."
  value       = module.this.eks_managed_node_groups
}
